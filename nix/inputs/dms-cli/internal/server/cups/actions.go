package cups

import (
	"strings"
	"time"

	"github.com/AvengeMedia/danklinux/pkg/ipp"
)

func (m *Manager) GetPrinters() ([]Printer, error) {
	attributes := []string{
		ipp.AttributePrinterName,
		ipp.AttributePrinterUriSupported,
		ipp.AttributePrinterState,
		ipp.AttributePrinterStateReasons,
		ipp.AttributePrinterLocation,
		ipp.AttributePrinterInfo,
		ipp.AttributePrinterMakeAndModel,
		ipp.AttributePrinterIsAcceptingJobs,
	}

	printerAttrs, err := m.client.GetPrinters(attributes)
	if err != nil {
		return nil, err
	}

	printers := make([]Printer, 0, len(printerAttrs))
	for _, attrs := range printerAttrs {
		printer := Printer{
			Name:        getStringAttr(attrs, ipp.AttributePrinterName),
			URI:         getStringAttr(attrs, ipp.AttributePrinterUriSupported),
			State:       parsePrinterState(attrs),
			StateReason: getStringAttr(attrs, ipp.AttributePrinterStateReasons),
			Location:    getStringAttr(attrs, ipp.AttributePrinterLocation),
			Info:        getStringAttr(attrs, ipp.AttributePrinterInfo),
			MakeModel:   getStringAttr(attrs, ipp.AttributePrinterMakeAndModel),
			Accepting:   getBoolAttr(attrs, ipp.AttributePrinterIsAcceptingJobs),
		}

		if printer.Name != "" {
			printers = append(printers, printer)
		}
	}

	return printers, nil
}

func (m *Manager) GetJobs(printerName string, whichJobs string) ([]Job, error) {
	attributes := []string{
		ipp.AttributeJobID,
		ipp.AttributeJobName,
		ipp.AttributeJobState,
		ipp.AttributeJobPrinterURI,
		ipp.AttributeJobOriginatingUserName,
		ipp.AttributeJobKilobyteOctets,
		"time-at-creation",
	}

	jobAttrs, err := m.client.GetJobs(printerName, "", whichJobs, false, 0, 0, attributes)
	if err != nil {
		return nil, err
	}

	jobs := make([]Job, 0, len(jobAttrs))
	for _, attrs := range jobAttrs {
		job := Job{
			ID:    getIntAttr(attrs, ipp.AttributeJobID),
			Name:  getStringAttr(attrs, ipp.AttributeJobName),
			State: parseJobState(attrs),
			User:  getStringAttr(attrs, ipp.AttributeJobOriginatingUserName),
			Size:  getIntAttr(attrs, ipp.AttributeJobKilobyteOctets) * 1024,
		}

		if uri := getStringAttr(attrs, ipp.AttributeJobPrinterURI); uri != "" {
			parts := strings.Split(uri, "/")
			if len(parts) > 0 {
				job.Printer = parts[len(parts)-1]
			}
		}

		if ts := getIntAttr(attrs, "time-at-creation"); ts > 0 {
			job.TimeCreated = time.Unix(int64(ts), 0)
		}

		if job.ID != 0 {
			jobs = append(jobs, job)
		}
	}

	return jobs, nil
}

func (m *Manager) CancelJob(jobID int) error {
	return m.client.CancelJob(jobID, false)
}

func (m *Manager) PausePrinter(printerName string) error {
	return m.client.PausePrinter(printerName)
}

func (m *Manager) ResumePrinter(printerName string) error {
	return m.client.ResumePrinter(printerName)
}

func (m *Manager) PurgeJobs(printerName string) error {
	return m.client.CancelAllJob(printerName, true)
}
