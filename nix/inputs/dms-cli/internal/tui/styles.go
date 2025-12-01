package tui

import (
	"github.com/charmbracelet/bubbles/progress"
	"github.com/charmbracelet/lipgloss"
)

type AppTheme struct {
	Primary    string
	Secondary  string
	Accent     string
	Text       string
	Subtle     string
	Error      string
	Warning    string
	Success    string
	Background string
	Surface    string
}

func TerminalTheme() AppTheme {
	return AppTheme{
		Primary:    "6",  // #625690 - purple
		Secondary:  "5",  // #36247a - dark purple
		Accent:     "12", // #7060ac - light purple
		Text:       "7",  // #2e2e2e - dark gray
		Subtle:     "8",  // #4a4a4a - medium gray
		Error:      "1",  // #d83636 - red
		Warning:    "3",  // #ffff89 - yellow
		Success:    "2",  // #53e550 - green
		Background: "15", // #1a1a1a - near black
		Surface:    "8",  // #4a4a4a - medium gray
	}
}

func NewStyles(theme AppTheme) Styles {
	return Styles{
		Title: lipgloss.NewStyle().
			Foreground(lipgloss.Color(theme.Primary)).
			Bold(true).
			MarginLeft(1).
			MarginBottom(1),

		Normal: lipgloss.NewStyle().
			Foreground(lipgloss.Color(theme.Text)),

		Bold: lipgloss.NewStyle().
			Foreground(lipgloss.Color(theme.Text)).
			Bold(true),

		Subtle: lipgloss.NewStyle().
			Foreground(lipgloss.Color(theme.Subtle)),

		Error: lipgloss.NewStyle().
			Foreground(lipgloss.Color(theme.Error)),

		Warning: lipgloss.NewStyle().
			Foreground(lipgloss.Color(theme.Warning)),

		StatusBar: lipgloss.NewStyle().
			Foreground(lipgloss.Color("#33275e")).
			Background(lipgloss.Color(theme.Primary)).
			Padding(0, 1),

		Key: lipgloss.NewStyle().
			Foreground(lipgloss.Color(theme.Accent)).
			Bold(true),

		SpinnerStyle: lipgloss.NewStyle().
			Foreground(lipgloss.Color(theme.Primary)),

		Success: lipgloss.NewStyle().
			Foreground(lipgloss.Color(theme.Success)).
			Bold(true),

		HighlightButton: lipgloss.NewStyle().
			Foreground(lipgloss.Color("#33275e")).
			Background(lipgloss.Color(theme.Primary)).
			Padding(0, 2).
			Bold(true),

		SelectedOption: lipgloss.NewStyle().
			Foreground(lipgloss.Color(theme.Accent)).
			Bold(true),

		CodeBlock: lipgloss.NewStyle().
			Background(lipgloss.Color(theme.Surface)).
			Foreground(lipgloss.Color(theme.Text)).
			Padding(1, 2).
			MarginLeft(2),
	}
}

type Styles struct {
	Title           lipgloss.Style
	Normal          lipgloss.Style
	Bold            lipgloss.Style
	Subtle          lipgloss.Style
	Warning         lipgloss.Style
	Error           lipgloss.Style
	StatusBar       lipgloss.Style
	Key             lipgloss.Style
	SpinnerStyle    lipgloss.Style
	Success         lipgloss.Style
	HighlightButton lipgloss.Style
	SelectedOption  lipgloss.Style
	CodeBlock       lipgloss.Style
}

func (s Styles) NewThemedProgress(width int) progress.Model {
	theme := TerminalTheme()
	prog := progress.New(
		progress.WithGradient(theme.Secondary, theme.Primary),
	)

	prog.Width = width
	prog.ShowPercentage = true
	prog.PercentFormat = "%.0f%%"
	prog.PercentageStyle = lipgloss.NewStyle().
		Foreground(lipgloss.Color(theme.Text)).
		Bold(true)

	return prog
}
