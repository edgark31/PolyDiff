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
    playerId?: string;
    name: string;
    differenceData: Differences;
}

export interface Observers {
    name: string;
}

export interface Lobby {
    lobbyId?: string;
    gameId: string;
    isAvailable: boolean;
    players: Player[];
    observers: Observers[];
    isCheatEnabled: boolean;
    mode: string;
    password?: string;
}

export interface Game {
    gameId?: string;
    original: string;
    modified: string;
    difficulty: string;
    differences: Coordinate[][];
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
}

export interface Profile {
    avatar: string;
    sessions: SessionLog[];
    connections: ConnectionLog[];
    stats: Statistics;
    friends: Friend[];
    friendRequests: string[];
    theme: Theme;
    language: string;
    songDifference: Song;
    songError: Song;
}

export interface SessionLog {
    timestamp: string;
    isWinner: boolean;
}

export interface ConnectionLog {
    timestamp: string;
    isConnexion: boolean;
}

export interface Statistics {
    gamePlayed: number;
    gameWon: number;
    averageTime: number;
    averageDifferences: number;
}

export interface Friend {
    name: string;
    avatar: string;
    friendNames: string[];
    commonFriendNames: string[];
    isFavorite: boolean;
    isOnline: boolean;
}

export interface Score {
    value: number;
    mode: string;
    duration: number;
    diffFound: number;
    difficulty: string;
}

export interface Chat {
    raw: string;
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

export interface Song {
    name: string;
    link: string;
}

// export interface modifyProfile {
//     avatar: string;
//     name: string;
//     theme: Theme;
//     language: string;
//     password: string;
// }
