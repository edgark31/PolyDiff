import { Coordinate } from '@common/coordinate';
import { GameModes, MessageTag } from '@common/enums';

export interface Players {
    player1: Player;
    player2?: Player;
}

export interface GameHistory {
    date: string;
    startingHour: string;
    duration: number;
    gameMode: string;
    player1: PlayerInfo;
    player2?: PlayerInfo;
}

export interface PlayerInfo {
    name: string;
    isWinner: boolean;
    isQuitter: boolean;
}

export interface ClientSideGame {
    id: string;
    name: string;
    mode: string;
    original: string;
    modified: string;
    isHard: boolean;
    differencesCount: number;
}

export interface GameCard {
    _id: string;
    name: string;
    difficultyLevel: boolean;
    soloTopTime: PlayerTime[];
    oneVsOneTopTime: PlayerTime[];
    thumbnail: string;
    nDifference?: number;
}

export interface CarouselPaginator {
    hasNext: boolean;
    hasPrevious: boolean;
    gameCards: GameCard[];
}

export interface GameConfigConst {
    countdownTime: number;
    penaltyTime: number;
    bonusTime: number;
}

export interface PlayerTime {
    name: string;
    time: number;
}

export interface GameRoom {
    roomId: string;
    clientGame: ClientSideGame;
    endMessage: string;
    timer: number;
    originalDifferences: Coordinate[][];
    gameConstants: GameConfigConst;
    player2?: Player;
    player1: Player;
}

export interface PlayerData {
    playerName: string;
    gameId: string;
    gameMode: GameModes;
}

export interface Differences {
    currentDifference: Coordinate[];
    differencesFound: number;
}

export interface RoomAvailability {
    gameId: string;
    isAvailableToJoin: boolean;
    hostId: string;
}

export interface PlayerNameAvailability {
    gameId: string;
    isNameAvailable: boolean;
}

export interface AcceptedPlayer {
    gameId: string;
    roomId: string;
    playerName: string;
}

export interface WaitingPlayerNameList {
    gameId: string;
    playerNamesList: string[];
}

export interface ChatMessage {
    tag: MessageTag;
    message: string;
}

export interface NewRecord {
    gameName: string;
    playerName: string;
    rank: number;
    gameMode: string;
}

export interface TimerMode {
    isCountdown: boolean;
    requiresPlayer2?: boolean;
}

export enum GameCardActions {
    Create = 'create',
    Join = 'join',
}

export { Coordinate };

export interface ChatMessageGlobal {
    tag: MessageTag;
    message: string;
    userName: string;
    timestamp?: string;
}

export interface Player {
    accountId?: string;
    name?: string;
    differenceData?: Differences;
    count?: number;
}

export interface Observer {
    accountId: string;
    name: string;
}

export interface Lobby {
    lobbyId?: string;
    gameId?: string; // creer en classique
    isAvailable: boolean; // true
    players: Player[]; // vide
    observers: Observer[]; // vide
    isCheatEnabled: boolean; // false
    mode: GameModes; // classique ou limited
    password?: string; // oui
    time?: number;
    timeLimit: number;
    bonusTime?: number;
    timePlayed: number;
    chatLog?: ChatLog;
    nDifferences?: number;
}

export interface Game {
    lobbyId: string;
    gameId: string;
    name: string;
    original: string;
    modified: string;
    difficulty?: string;
    differences?: Coordinate[][];
    nDifferences?: number;
    playedGameIds?: string[];
}

export interface Account {
    id?: string;
    credentials: Credentials;
    profile: Profile;
}

export interface Credentials {
    username: string;
    password: string;
    email?: string;
    recuperatePasswordCode?: string;
}

export interface Profile {
    avatar: string;
    sessions: SessionLog[];
    connections: ConnectionLog[];
    stats: Statistics;
    friends: Friend[];
    friendRequests: string[];
    desktopTheme: Theme;
    language: string;
    onCorrectSound: Sound;
    onErrorSound: Sound;
}

export interface Friend {
    name: string;
    accountId: string;
    friends?: Friend[]; // Ne contient que name et accountId
    commonFriends?: Friend[]; // Ne contient que name et accountId
    isFavorite?: boolean;
    isOnline?: boolean;
}

export interface User {
    name: string;
    accountId: string;
    friends: Friend[]; // Ne contient que name et accountId
    friendRequests: string[];
}

export interface SessionLog {
    timestamp: string;
    isWinner: boolean;
}

export interface ConnectionLog {
    timestamp: string;
    isConnection: boolean;
}

export interface Statistics {
    gamesPlayed: number;
    gameWon: number;
    averageTime: number;
    averageDifferences: number;
}

export interface Chat {
    raw: string;
    accountId?: string;
    name?: string;
    tag?: MessageTag;
    timestamp?: string;
}

export interface ChatLog {
    chat: Chat[];
    channelName: string;
}

export interface Replay {
    name: string;
    actions: string[];
    mode: string;
    timestamps: string;
}

export interface Theme {
    name: string;
    color: string;
    backgroundColor: string;
    buttonColor: string;
}

export interface Sound {
    name: string;
    path: string;
}

export interface GameEventData {
    accountId?: string;
    username?: string;
    timestamp?: number;
    players?: Player[];
    gameEvent: string;
    coordClic?: Coordinate;
    remainingDifferenceIndex?: number[];
    isMainCanvas?: boolean;
}

export interface GameRecord {
    game: Game;
    players: Player[];
    accountIds: string[];
    date: Date;
    startTime: number;
    endTime: number;
    duration: number;
    isCheatEnabled: boolean;
    timeLimit: number;
    gameEvents: GameEventData[];
}

export interface RankedPlayer {
    accountId: string;
    name: string;
    rank: number;
    stats: Statistics;
}