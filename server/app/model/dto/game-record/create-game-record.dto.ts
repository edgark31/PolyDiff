/* eslint-disable @typescript-eslint/member-ordering */
import { Game, GameEventData, Player } from '@common/game-interfaces';
import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsNumber } from 'class-validator';

export class CreateGameRecordDto {
    @ApiProperty()
    @IsNumber()
    accountIds: string[];

    game: Game;

    players: Player[];

    date: Date;

    @ApiProperty()
    @IsNumber()
    startTime: number;

    @ApiProperty()
    @IsNumber()
    endTime: number;

    @ApiProperty()
    @IsNumber()
    duration: number;

    @ApiProperty()
    @IsBoolean()
    isCheatEnabled: boolean;

    @ApiProperty()
    @IsNumber()
    timeLimit: number;

    gameEvents: GameEventData[];
}
