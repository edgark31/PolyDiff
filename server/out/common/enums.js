"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ConnectionEvents = exports.GamePageEvent = exports.MessageTag = exports.MessageEvents = exports.GameModes = exports.PlayerStatus = exports.RoomEvents = exports.HistoryEvents = exports.GameCardEvents = exports.PlayerEvents = exports.GameEvents = void 0;
var GameEvents;
(function (GameEvents) {
    GameEvents["ValidateCoords"] = "ValidateCoords";
    GameEvents["CheckStatus"] = "CheckStatus";
    GameEvents["EndGame"] = "EndGame";
    GameEvents["TimerUpdate"] = "TimerUpdate";
    GameEvents["RemoveDifference"] = "removeDifference";
    GameEvents["GameStarted"] = "GameStarted";
    GameEvents["AbandonGame"] = "AbandonGame";
    GameEvents["StartGameByRoomId"] = "CreateOneVsOneGame";
    GameEvents["StartNextGame"] = "StartNextGame";
    GameEvents["RequestHint"] = "RequestHint";
    GameEvents["UpdateDifferencesFound"] = "UpdateDifferencesFound";
    GameEvents["GameModeChanged"] = "GameModeChanged";
    GameEvents["GamePageRefreshed"] = "Refresh";
})(GameEvents = exports.GameEvents || (exports.GameEvents = {}));
var PlayerEvents;
(function (PlayerEvents) {
    PlayerEvents["PlayerRefused"] = "PlayerRefused";
    PlayerEvents["GetJoinedPlayerNames"] = "GetJoinedPlayerNames";
    PlayerEvents["PlayerAccepted"] = "PlayerAccepted";
    PlayerEvents["AcceptPlayer"] = "AcceptPlayer";
    PlayerEvents["CancelJoining"] = "CancelJoining";
    PlayerEvents["RefusePlayer"] = "RefusePlayer";
    PlayerEvents["PlayerNameTaken"] = "PlayerNameTaken";
    PlayerEvents["UpdateWaitingPlayerNameList"] = "UpdateWaitingPlayerNameList";
    PlayerEvents["CheckIfPlayerNameIsAvailable"] = "CheckIfPlayerNameIsAvailable";
    PlayerEvents["WaitingPlayerNameListUpdated"] = "WaitingPlayerNameListUpdated";
})(PlayerEvents = exports.PlayerEvents || (exports.PlayerEvents = {}));
var GameCardEvents;
(function (GameCardEvents) {
    GameCardEvents["ResetTopTime"] = "ResetTopTime";
    GameCardEvents["ResetAllTopTimes"] = "ResetAllTopTimes";
    GameCardEvents["GameCardDeleted"] = "GameCardDeleted";
    GameCardEvents["GameCardCreated"] = "GameCardCreated";
    GameCardEvents["RequestReload"] = "RequestReload";
    GameCardEvents["AllGamesDeleted"] = "AllGamesDeleted";
    GameCardEvents["GameDeleted"] = "GameDeleted";
    GameCardEvents["GameConstantsUpdated"] = "GameConstantsUpdated";
    GameCardEvents["GamesHistoryDeleted"] = "GamesHistoryDeleted";
})(GameCardEvents = exports.GameCardEvents || (exports.GameCardEvents = {}));
var HistoryEvents;
(function (HistoryEvents) {
    HistoryEvents["RequestReload"] = "RequestReload";
})(HistoryEvents = exports.HistoryEvents || (exports.HistoryEvents = {}));
var RoomEvents;
(function (RoomEvents) {
    RoomEvents["CreateClassicSoloRoom"] = "CreateClassicSoloRoom";
    RoomEvents["RoomSoloCreated"] = "RoomSoloCreated";
    RoomEvents["RoomLimitedCreated"] = "RoomLimitedCreated";
    RoomEvents["CreateLimitedRoom"] = "CreateSoloLimitedRoom";
    RoomEvents["RoomOneVsOneCreated"] = "RoomOneVsOneCreated";
    RoomEvents["RoomOneVsOneAvailable"] = "RoomOneVsOneAvailable";
    RoomEvents["CreateOneVsOneRoom"] = "CreateOneVsOneRoom";
    RoomEvents["CreateCoopLimitedRoom"] = "CreateCoopLimitedRoom";
    RoomEvents["CheckRoomOneVsOneAvailability"] = "CheckRoomOneVsOneAvailability";
    RoomEvents["UpdateRoomOneVsOneAvailability"] = "UpdateRoomOneVsOneAvailability";
    RoomEvents["OneVsOneRoomDeleted"] = "OneVsOneRoomDeleted";
    RoomEvents["UndoRoomCreation"] = "UndoRoomCreation";
    RoomEvents["DeleteCreatedOneVsOneRoom"] = "DeleteCreatedOneVsOneRoom";
    RoomEvents["JoinOneVsOneRoom"] = "JoinOneVsOneRoom";
    RoomEvents["CheckIfAnyCoopRoomExists"] = "CheckIfAnyCoopRoomExists";
    RoomEvents["LimitedCoopRoomJoined"] = "LimitedCoopRoomJoined";
    RoomEvents["DeleteCreatedCoopRoom"] = "DeleteCreatedCoopRoom";
    RoomEvents["NoGameAvailable"] = "NoGameAvailable";
})(RoomEvents = exports.RoomEvents || (exports.RoomEvents = {}));
var PlayerStatus;
(function (PlayerStatus) {
    PlayerStatus["Winner"] = "Winner";
    PlayerStatus["Quitter"] = "Quitter";
})(PlayerStatus = exports.PlayerStatus || (exports.PlayerStatus = {}));
var GameModes;
(function (GameModes) {
    GameModes["ClassicSolo"] = "Classic->Solo";
    GameModes["ClassicOneVsOne"] = "Classic->OneVsOne";
    GameModes["LimitedSolo"] = "Limited->Solo";
    GameModes["LimitedCoop"] = "Limited->Coop";
})(GameModes = exports.GameModes || (exports.GameModes = {}));
var MessageEvents;
(function (MessageEvents) {
    MessageEvents["LocalMessage"] = "LocalMessage";
    MessageEvents["GlobalMessage"] = "GlobalMessage";
})(MessageEvents = exports.MessageEvents || (exports.MessageEvents = {}));
var MessageTag;
(function (MessageTag) {
    MessageTag["Sent"] = "Sent";
    MessageTag["Received"] = "Received";
    MessageTag["Common"] = "Common";
    MessageTag["Global"] = "Global";
})(MessageTag = exports.MessageTag || (exports.MessageTag = {}));
var GamePageEvent;
(function (GamePageEvent) {
    GamePageEvent["EndGame"] = "EndGame";
    GamePageEvent["Abandon"] = "Abandon";
})(GamePageEvent = exports.GamePageEvent || (exports.GamePageEvent = {}));
var ConnectionEvents;
(function (ConnectionEvents) {
    ConnectionEvents["UserConnectionRequest"] = "UserConnectionRequest";
    ConnectionEvents["UserDeconnectionRequest"] = "UserDeconnectionRequest";
})(ConnectionEvents = exports.ConnectionEvents || (exports.ConnectionEvents = {}));
//# sourceMappingURL=enums.js.map