# SA-MP events (from lib/samp/events.lua)

Source: `lib/samp/events.lua` (verified). Event names are the strings mapped there. Signature shape follows the mapping; custom handlers (reader/writer pairs) are noted.

## Outgoing RPCs (onSend*)

onSendEnterVehicle, onSendClickPlayer, onSendClientJoin, onSendEnterEditObject, onSendCommand, onSendSpawn, onSendDeathNotification, onSendDialogResponse, onSendClickTextDraw, onSendVehicleTuningNotification, onSendChat, onSendClientCheckResponse, onSendVehicleDamaged, onSendEditAttachedObject, onSendEditObject, onSendInteriorChangeNotification, onSendMapMarker, onSendRequestClass, onSendRequestSpawn, onSendPickedUpPickup, onSendMenuSelect, onSendVehicleDestroyed, onSendQuitMenu, onSendExitVehicle, onSendUpdateScoresAndPings, onSendGiveDamage / onSendTakeDamage (custom), onSendMoneyIncreaseNotification, onSendNPCJoin, onSendServerStatisticsRequest, onSendPickedUpWeapon, onSendCameraTargetUpdate, onSendGiveActorDamage.

## Incoming RPCs (on*)

onInitGame (custom), onPlayerJoin, onPlayerQuit, onRequestClassResponse, onRequestSpawnResponse, onSetPlayerName, onSetPlayerPos, onSetPlayerPosFindZ, onSetPlayerHealth, onTogglePlayerControllable, onPlaySound, onSetWorldBounds, onGivePlayerMoney, onSetPlayerFacingAngle, onResetPlayerMoney, onResetPlayerWeapons, onGivePlayerWeapon, onCancelEdit, onSetPlayerTime, onSetToggleClock, onPlayerStreamIn, onSetShopName, onSetPlayerSkillLevel, onSetPlayerDrunk, onCreate3DText, onDisableCheckpoint, onSetRaceCheckpoint, onDisableRaceCheckpoint, onGamemodeRestart, onPlayAudioStream, onStopAudioStream, onRemoveBuilding, onCreateObject (custom), onSetObjectPosition, onSetObjectRotation, onDestroyObject, onPlayerDeathNotification, onSetMapIcon, onRemoveVehicleComponent, onRemove3DTextLabel, onPlayerChatBubble, onUpdateGlobalTimer, onShowDialog, onDestroyPickup, onLinkVehicleToInterior, onSetPlayerArmour, onSetPlayerArmedWeapon, onSetSpawnInfo, onSetPlayerTeam, onPutPlayerInVehicle, onRemovePlayerFromVehicle, onSetPlayerColor, onDisplayGameText, onForceClassSelection, onAttachObjectToPlayer, onInitMenu (custom), onShowMenu, onHideMenu, onCreateExplosion, onShowPlayerNameTag, onAttachCameraToObject, onInterpolateCamera, onGangZoneStopFlash, onApplyPlayerAnimation, onClearPlayerAnimation, onSetPlayerSpecialAction, onSetPlayerFightingStyle, onSetPlayerVelocity, onSetVehicleVelocity, onServerMessage, onSetWorldTime, onCreatePickup, onMoveObject, onEnableStuntBonus, onTextDrawSetString, onSetCheckpoint, onCreateGangZone, onPlayCrimeReport, onSetPlayerAttachedObject, onGangZoneDestroy, onGangZoneFlash, onStopObject, onSetVehicleNumberPlate, onTogglePlayerSpectating, onSpectatePlayer, onSpectateVehicle, onSetPlayerWantedLevel, onTextDrawHide, onRemoveMapIcon, onSetWeaponAmmo, onSetGravity, onSetVehicleHealth, onAttachTrailerToVehicle, onDetachTrailerFromVehicle, onSetWeather, onSetPlayerSkin, onSetInterior, onSetCameraPosition, onSetCameraLookAt, onSetVehiclePosition, onSetVehicleAngle, onSetVehicleParams, onSetCameraBehind, onChatMessage, onConnectionRejected, onPlayerStreamOut, onVehicleStreamIn (custom), onVehicleStreamOut, onPlayerDeath, onPlayerEnterVehicle, onUpdateScoresAndPings (custom), onSetObjectMaterial / onSetObjectMaterialText (custom), onCreateActor, onToggleSelectTextDraw, onSetVehicleParamsEx, onSetPlayerAttachedObject, onClientCheck, onDestroyActor, onDestroyWeaponPickup, onEditAttachedObject, onToggleCameraTargetNotifying, onEnterSelectObject, onPlayerExitVehicle, onVehicleTuningNotification, onServerStatisticsResponse, onEnterEditObject, onVehicleDamageStatusUpdate, onDisableVehicleCollisions, onToggleWidescreen, onSetVehicleTires, onSetPlayerDrunkVisuals, onSetPlayerDrunkHandling, onApplyActorAnimation, onClearActorAnimation, onSetActorFacingAngle, onSetActorPos, onSetActorHealth, onSetPlayerObjectNoCameraCol, plus `_dummy125`, `_dummy64`, `_unused48`.

## Outgoing packets (onSend*)

onSendRconCommand, onSendStatsUpdate, onSendPlayerSync, onSendVehicleSync, onSendPassengerSync, onSendAimSync, onSendUnoccupiedSync, onSendTrailerSync, onSendBulletSync, onSendSpectatorSync, onSendWeaponsUpdate, onSendAuthenticationResponse.

## Incoming packets (on*)

onPlayerSync, onVehicleSync, onMarkersSync, onAimSync, onBulletSync, onUnoccupiedSync, onTrailerSync, onPassengerSync, onAuthenticationRequest, onConnectionRequestAccepted, onConnectionLost, onConnectionBanned, onConnectionAttemptFailed, onConnectionNoFreeSlot, onConnectionPasswordInvalid, onConnectionClosed.

## Notes

- Event functions are global by name. Define them at top level after `require 'samp.events'`.
- Handlers for sync packets receive `(playerId, data)` or `(playerId, vehicleId, data)`; see `references/sync.md`.
- Returning `false` consumes the event; returning a table rewrites; returning nil passes through.
- `lib/samp/events/extra_types.lua` is required by `events.lua` for additional types; do not remove.
