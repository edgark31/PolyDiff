import { ComponentFixture, TestBed } from '@angular/core/testing';

import { WaitingGameDialogComponent } from './waiting-game-dialog.component';

describe('WaitingGameDialogComponent', () => {
    let component: WaitingGameDialogComponent;
    let fixture: ComponentFixture<WaitingGameDialogComponent>;

    beforeEach(async () => {
        await TestBed.configureTestingModule({
            declarations: [WaitingGameDialogComponent],
        }).compileComponents();

        fixture = TestBed.createComponent(WaitingGameDialogComponent);
        component = fixture.componentInstance;
        fixture.detectChanges();
    });

    it('should create', () => {
        expect(component).toBeTruthy();
    });
});
