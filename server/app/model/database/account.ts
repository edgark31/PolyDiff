// eslint-disable-next-line max-classes-per-file
import { ConnectionLog } from '@common/game-interfaces';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ApiProperty } from '@nestjs/swagger';
import { Document } from 'mongoose';

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
export class Song {
    @Prop({ required: true })
    name: string;

    @Prop({ required: false })
    link: string;
}

export const songSchema = SchemaFactory.createForClass(Song);

@Schema({ _id: false })
export class ConnexionLog {
    @Prop({ required: true })
    timestamp: string;

    @Prop({ required: true })
    isConnexion: boolean;
}

export const connexionLogSchema = SchemaFactory.createForClass(ConnexionLog);

@Schema({ _id: false })
export class Statistics {
    @Prop({ required: true })
    gamePlayed: number;

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
    avatar: string;

    @Prop({ type: [String] })
    friendNames: string[];

    @Prop({ type: [String] })
    commonFriendNames: string[];

    @Prop({ required: true })
    isFavorite: boolean;

    @Prop({ required: true })
    isOnline: boolean;
}

export const friendSchema = SchemaFactory.createForClass(Friend);

@Schema({ _id: false })
export class Profile {
    @Prop({ required: true })
    avatar: string;

    @Prop({ type: [sessionLogSchema], default: [] })
    sessions: SessionLog[];

    @Prop({ type: [connexionLogSchema], default: [] })
    connections: ConnectionLog[];

    @Prop({ type: statisticsSchema, required: true })
    stats: Statistics;

    @Prop({ type: [friendSchema], default: [] })
    friends: Friend[];

    @Prop({ type: [String], default: [] })
    friendRequests: string[];

    @Prop({ required: false })
    language: string;

    @Prop({ type: themeSchema, required: false })
    theme: Theme;

    @Prop({ type: songSchema, required: false })
    songDifference: Song;

    @Prop({ type: songSchema, required: false })
    songError: Song;
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
