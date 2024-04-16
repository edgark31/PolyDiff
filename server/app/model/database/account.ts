// eslint-disable-next-line max-classes-per-file
import { Prop, Schema, SchemaFactory, raw } from '@nestjs/mongoose';
import { ApiProperty } from '@nestjs/swagger';
import { Document, Types } from 'mongoose';

@Schema({ _id: false })
export class SessionLog {
    @Prop({ required: true })
    timestamp: string;

    @Prop({ required: true })
    isWinner: boolean;
}

export const sessionLogSchema = SchemaFactory.createForClass(SessionLog);

@Schema({ _id: false })
export class Theme {
    @Prop({ required: true })
    name: string;

    @Prop({ required: false })
    color: string;

    @Prop({ required: false })
    backgroundColor: string;

    @Prop({ required: false })
    buttonColor: string;
}

export const themeSchema = SchemaFactory.createForClass(Theme);

@Schema({ _id: false })
export class Sound {
    @Prop({ required: true })
    name: string;

    @Prop({ required: false })
    path: string;
}

export const soundSchema = SchemaFactory.createForClass(Sound);

@Schema({ _id: false })
export class ConnectionLog {
    @Prop({ required: true })
    timestamp: string;

    @Prop({ required: true })
    isConnection: boolean;
}

export const connectionLogSchema = SchemaFactory.createForClass(ConnectionLog);

@Schema({ _id: false })
export class Statistics {
    @Prop({ required: true })
    gamesPlayed: number;

    @Prop({ required: true })
    gameWon: number;

    @Prop({ required: true })
    averageTime: number;

    @Prop({ required: true })
    averageDifferences: number;
}

export const statisticsSchema = SchemaFactory.createForClass(Statistics);

@Schema({ _id: false })
export class Friend {
    @Prop({ required: true })
    name: string;

    @Prop({ required: true })
    accountId: string;

    @Prop(
        raw([
            {
                type: Types.ObjectId,
                ref: 'Friend',
            },
        ]),
    )
    friends?: Friend[];

    @Prop(
        raw([
            {
                type: Types.ObjectId,
                ref: 'Friend',
            },
        ]),
    )
    commonFriends?: Friend[];

    @Prop({ required: false })
    isFavorite?: boolean;

    @Prop({ required: false })
    isOnline?: boolean;
}

export const friendSchema = SchemaFactory.createForClass(Friend);

@Schema({ _id: false })
export class Profile {
    @Prop({ required: false })
    avatar: string;

    @Prop({ type: [sessionLogSchema], default: [] })
    sessions: SessionLog[];

    @Prop({ type: [connectionLogSchema], default: [] })
    connections: ConnectionLog[];

    @Prop({ type: statisticsSchema, required: true })
    stats: Statistics;

    @Prop({ type: [friendSchema], default: [] })
    friends: Friend[];

    @Prop({ type: [String], default: [] })
    friendRequests: string[];

    @Prop({ required: false })
    language: string;

    @Prop({ type: String, required: false })
    mobileTheme: string;

    @Prop({ type: soundSchema, required: false })
    onCorrectSound: Sound;

    @Prop({ type: soundSchema, required: false })
    onErrorSound: Sound;
}

export const profileSchema = SchemaFactory.createForClass(Profile);

@Schema({ _id: false })
export class Credentials {
    @Prop({ required: true })
    username: string;

    @Prop({ required: true })
    password: string;

    @Prop()
    email: string;

    @Prop({ required: false })
    recuperatePasswordCode: string;
}

export const credentialsSchema = SchemaFactory.createForClass(Credentials);

@Schema()
export class Account {
    @ApiProperty()
    @Prop()
    id?: string;

    @ApiProperty()
    @Prop({ required: true, type: credentialsSchema })
    credentials: Credentials;

    @ApiProperty()
    @Prop({ required: true, type: profileSchema })
    profile: Profile;
}

export type AccountDocument = Account & Document;
export const accountSchema = SchemaFactory.createForClass(Account);
