import { Injectable } from '@angular/core';
import { io, Socket } from 'socket.io-client';
import { environment } from 'src/environments/environment';
// This code belongs to Nikolay Radoev
// https://gitlab.com/nikolayradoev/socket-io-exemple/-/tree/master

@Injectable({
    providedIn: 'root',
})
export class ClientSocketService {
    socket: Socket;
    chatSocket: Socket;
    authSocket: Socket;
    private readonly baseUrl: string;
    constructor() {
        this.baseUrl = environment.serverUrl.replace('/api', '');
    }

    isSocketAlive() {
        return this.socket && this.socket.connected;
    }

    connect(userName: string, nameSpace: string) {
        switch (nameSpace) {
            case 'chat':
                this.chatSocket = io(this.baseUrl, { transports: ['websocket'], upgrade: false, query: { name: userName } });
                break;
            case 'auth':
                this.authSocket = io(this.baseUrl, { transports: ['websocket'], upgrade: false, query: { name: userName } });
                break;
            default:
                throw new Error(`Unknown namespace: ${nameSpace}`);
        }
    }

    disconnect() {
        this.socket.disconnect();
    }

    on<T>(event: string, action: (data: T) => void): void {
        this.socket.on(event, action);
    }

    send<T>(event: string, data?: T): void {
        if (data) {
            this.socket.emit(event, data);
        } else {
            this.socket.emit(event);
        }
    }
}
