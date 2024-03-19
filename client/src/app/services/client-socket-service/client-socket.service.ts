import { Injectable } from '@angular/core';
import { io, Socket } from 'socket.io-client';
import { environment } from 'src/environments/environment';
// This code belongs to Nikolay Radoev
// https://gitlab.com/nikolayradoev/socket-io-exemple/-/tree/master

@Injectable({
    providedIn: 'root',
})
export class ClientSocketService {
    lobbySocket: Socket;
    gameSocket: Socket;
    authSocket: Socket;
    private readonly baseUrl: string;
    constructor() {
        this.baseUrl = environment.serverUrl.replace('/api', '');
    }

    isSocketAlive(nameSpace: string): boolean {
        switch (nameSpace) {
            case 'lobby':
                return this.lobbySocket && this.lobbySocket.connected;
            case 'game':
                return this.gameSocket && this.gameSocket.connected;
            case 'auth':
                return this.authSocket && this.authSocket.connected;
            default:
                throw new Error(`Unknown namespace: ${nameSpace}`);
        }
    }

    connect(userId: string, nameSpace: string) {
        switch (nameSpace) {
            case 'lobby':
                this.lobbySocket = io(`${this.baseUrl}/${nameSpace}`, { transports: ['websocket'], upgrade: false, query: { id: userId } });
                break;
            case 'game':
                this.gameSocket = io(`${this.baseUrl}/${nameSpace}`, { transports: ['websocket'], upgrade: false, query: { id: userId } });
                break;
            case 'auth':
                this.authSocket = io(this.baseUrl, { transports: ['websocket'], upgrade: false, query: { id: userId } });
                break;
            default:
                throw new Error(`Unknown namespace: ${nameSpace}`);
        }
    }

    disconnect(nameSpace: string) {
        switch (nameSpace) {
            case 'lobby':
                this.lobbySocket.disconnect();
                break;
            case 'game':
                this.gameSocket.disconnect();
                break;
            case 'auth':
                this.authSocket.disconnect();
                break;
            default:
                throw new Error(`Unknown namespace: ${nameSpace}`);
        }
    }

    on<T>(nameSpace: string, event: string, action: (data: T) => void): void {
        switch (nameSpace) {
            case 'lobby':
                this.lobbySocket.on(event, action);
                break;
            case 'game':
                this.gameSocket.on(event, action);
                break;
            case 'auth':
                this.authSocket.on(event, action);
                break;
            default:
                throw new Error(`Unknown namespace: ${nameSpace}`);
        }
    }

    send<T>(nameSpace: string, event: string, data?: T): void {
        switch (nameSpace) {
            case 'lobby':
                this.lobbySocket.emit(event, data || undefined);
                break;
            case 'game':
                this.gameSocket.emit(event, data || undefined);
                break;
            case 'auth':
                this.authSocket.emit(event, data || undefined);
                break;
            default:
                throw new Error(`Unknown namespace: ${nameSpace}`);
        }
    }
}
