import { Component } from '@angular/core';

@Component({
    selector: 'app-create-room-page',
    templateUrl: './create-room-page.component.html',
    styleUrls: ['./create-room-page.component.scss'],
})
export class CreateRoomPageComponent {
    isCheatModeEnabled = false;
    formatLabel(value: number | null) {
        return value + ' sec';
    }
}
