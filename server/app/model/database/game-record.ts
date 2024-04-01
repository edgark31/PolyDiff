/* eslint-disable no-undef */
// eslint-disable-next-line max-classes-per-file
import { Coordinate, Game, GameEventData, Player } from '@common/game-interfaces';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ApiProperty } from '@nestjs/swagger';

export type GameRecordDocument = GameRecord & Document;

@Schema()
export class GameRecord {
    @ApiProperty()
    @Prop({
        required: true,
        type: () => ({
            lobbyId: String,
            gameId: String,
            name: String,
            original: String,
            modified: String,
            difficulty: String,
            differences: Array<Coordinate[]>,
            nDifferences: Number,
        }),
    })
    game: Game;

    @ApiProperty()
    @Prop({ required: true })
    players: Player[];

    // account ids of the players who saved the recorded game
    @ApiProperty()
    @Prop()
    accountIds: string[];

    @ApiProperty()
    @Prop({ required: true })
    date: number;

    @ApiProperty()
    @Prop()
    startTime: number;

    @ApiProperty()
    @Prop()
    endTime: number;

    @ApiProperty()
    @Prop()
    duration: number;

    @ApiProperty()
    @Prop({ required: true })
    isCheatEnabled: boolean;

    @ApiProperty()
    @Prop({ required: true })
    timeLimit: number;

    @ApiProperty()
    @Prop({ required: true })
    gameEvents: GameEventData[];
}

export const gameRecordSchema = SchemaFactory.createForClass(GameRecord);
