package tui

type ApplicationState int

const (
	StateWelcome ApplicationState = iota
	StateSelectWindowManager
	StateSelectTerminal
	StateMissingWMInstructions
	StateDetectingDeps
	StateDependencyReview
	StateAuthMethodChoice
	StateFingerprintAuth
	StatePasswordPrompt
	StateInstallingPackages
	StateConfigConfirmation
	StateDeployingConfigs
	StateInstallComplete
	StateFinalComplete
	StateError
)
