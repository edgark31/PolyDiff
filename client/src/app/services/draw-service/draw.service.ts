import { Injectable } from '@angular/core';
import { IMG_HEIGHT, IMG_WIDTH } from '@app/constants/image';
import { CanvasAction } from '@app/enum/canvas-action';
import { CanvasPosition } from '@app/enum/canvas-position';
import { Coordinate } from '@common/coordinate';

@Injectable({
    providedIn: 'root',
})
export class DrawService {
    private activeContext: CanvasRenderingContext2D;
    private activeCanvasPosition: CanvasPosition;
    private isMouseBeingDragged: boolean;
    private isSquareModeOn: boolean;
    private isCircleModeOn: boolean;
    private rectangleTopCorner: Coordinate;
    private ellipseCenter: Coordinate;
    private currentAction: CanvasAction;
    private clickPosition: Coordinate;
    private isMouseOutOfCanvas: boolean;
    private drawingColor: string;
    private pencilWidth: number;
    private eraserLength: number;

    constructor() {
        this.isMouseBeingDragged = false;
    }

    getActiveCanvasPosition(): CanvasPosition {
        return this.activeCanvasPosition;
    }

    mouseIsOutOfCanvas(): void {
        this.isMouseOutOfCanvas = true;
    }

    setDrawingColor(color: string): void {
        this.drawingColor = color;
    }

    setCanvasAction(canvasAction: CanvasAction): void {
        this.currentAction = canvasAction;
    }

    setPencilWidth(width: number): void {
        this.pencilWidth = width;
    }

    setEraserLength(width: number): void {
        this.eraserLength = width;
    }

    setActiveCanvasPosition(canvasPosition: CanvasPosition): void {
        this.activeCanvasPosition = canvasPosition;
    }

    setActiveContext(context: CanvasRenderingContext2D): void {
        this.activeContext = context;
    }

    setClickPosition(event: MouseEvent) {
        this.clickPosition = { x: event.offsetX, y: event.offsetY };
    }

    isCurrentActionRectangle(): boolean {
        return this.currentAction === CanvasAction.Rectangle;
    }

    isCurrentActionEllipse(): boolean {
        return this.currentAction === CanvasAction.Ellipse;
    }

    isMouseDragged(): boolean {
        return this.isMouseBeingDragged;
    }

    isOperationValid(canvasPosition: CanvasPosition): boolean {
        return this.isMouseBeingDragged && this.activeCanvasPosition === canvasPosition;
    }

    disableMouseDrag(): void {
        if (this.isMouseBeingDragged) {
            this.isMouseBeingDragged = false;
        }
    }

    startOperation() {
        this.isMouseBeingDragged = true;
        this.isSquareModeOn = false;
        this.isCircleModeOn = false;
        this.setCanvasOperationStyle();
        if (this.isCurrentActionRectangle()) {
            this.rectangleTopCorner = this.clickPosition;
        } else if (this.isCurrentActionEllipse()) {
            this.ellipseCenter = this.clickPosition;
        } else {
            this.activeContext.beginPath();
            this.drawLine();
        }
    }

    continueCanvasOperation(canvasPosition: CanvasPosition, event: MouseEvent) {
        this.setClickPosition(event);
        if (this.isOperationValid(canvasPosition)) {
            if (this.isMouseOutOfCanvas) {
                this.activeContext.closePath();
                this.activeContext.beginPath();
                this.isMouseOutOfCanvas = false;
            }
            this.drawCanvasOperation();
        }
    }

    stopOperation() {
        this.drawCanvasOperation();
        this.disableMouseDrag();
    }

    setSquareMode(isSquareModeOn: boolean) {
        if (this.isMouseBeingDragged && this.isCurrentActionRectangle() && !this.isMouseOutOfCanvas) {
            this.drawRectangle();
            this.isSquareModeOn = isSquareModeOn;
        }
    }

    setCircleMode(isCircleModeOn: boolean) {
        if (this.isMouseBeingDragged && this.isCurrentActionEllipse() && !this.isMouseOutOfCanvas) {
            this.drawEllipse();
            this.isCircleModeOn = isCircleModeOn;
        }
    }

    private drawCanvasOperation() {
        if (this.isCurrentActionRectangle()) {
            this.drawRectangle();
        } else if (this.isCurrentActionEllipse()) {
            this.drawEllipse();
        } else {
            this.drawLine();
        }
    }

    private setCanvasOperationStyle() {
        if (this.isCurrentActionRectangle()) {
            this.activeContext.globalCompositeOperation = 'source-over';
            this.activeContext.fillStyle = this.drawingColor;
        } else if (this.isCurrentActionEllipse()) {
            this.activeContext.globalCompositeOperation = 'source-over';
            this.activeContext.fillStyle = this.drawingColor;
        } else {
            this.activeContext.strokeStyle = this.drawingColor;
            this.activeContext.lineJoin = 'round';
            this.activeContext.globalCompositeOperation = this.currentAction === CanvasAction.Pencil ? 'source-over' : 'destination-out';
            this.activeContext.lineCap = this.currentAction === CanvasAction.Pencil ? 'round' : 'square';
            this.activeContext.lineWidth = this.currentAction === CanvasAction.Pencil ? this.pencilWidth : this.eraserLength;
        }
    }

    private drawRectangle() {
        this.activeContext.clearRect(0, 0, IMG_WIDTH, IMG_HEIGHT);
        const rectangleWidth: number = this.clickPosition.x - this.rectangleTopCorner.x;
        const drawingHeight: number = this.clickPosition.y - this.rectangleTopCorner.y;
        let rectangleHeight: number = this.isSquareModeOn ? rectangleWidth : drawingHeight;
        if (this.isSquareModeOn && drawingHeight < 0 !== (rectangleHeight < 0 || rectangleWidth < 0)) {
            rectangleHeight = -rectangleHeight;
        }
        this.activeContext.fillRect(this.rectangleTopCorner.x, this.rectangleTopCorner.y, rectangleWidth, rectangleHeight);
    }

    private drawEllipse() {
        this.activeContext.clearRect(0, 0, IMG_WIDTH, IMG_HEIGHT);
        this.activeContext.beginPath();
        if (this.isCircleModeOn) {
            const radius: number = Math.abs(this.clickPosition.x - this.ellipseCenter.x);
            this.activeContext.ellipse(this.ellipseCenter.x, this.ellipseCenter.y, radius, radius, 0, 0, 2 * Math.PI);
        } else {
            const radiusX: number = Math.abs(this.clickPosition.x - this.ellipseCenter.x);
            const radiusY: number = Math.abs(this.clickPosition.y - this.ellipseCenter.y);
            this.activeContext.ellipse(this.ellipseCenter.x, this.ellipseCenter.y, radiusX, radiusY, 0, 0, 2 * Math.PI);
        }
        this.activeContext.fill();
        this.activeContext.closePath();
    }

    private drawLine() {
        this.activeContext.lineTo(this.clickPosition.x, this.clickPosition.y);
        this.activeContext.stroke();
    }
}
