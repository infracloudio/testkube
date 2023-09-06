package templates

import (
	"strings"

	"github.com/spf13/cobra"

	"github.com/kubeshop/testkube/cmd/kubectl-testkube/commands/common"
	"github.com/kubeshop/testkube/pkg/ui"
)

func NewDeleteTemplateCmd() *cobra.Command {
	var name string
	var selectors []string

	cmd := &cobra.Command{

		Use:     "template <templateName>",
		Aliases: []string{"tp"},
		Short:   "Delete template",
		Long:    `Delete template, pass template name which should be deleted`,
		Run: func(cmd *cobra.Command, args []string) {
			client, _, err := common.GetClient(cmd)
			ui.ExitOnError("getting client", err)

			if len(args) > 0 {
				name = args[0]
				err := client.DeleteTemplate(name)
				ui.ExitOnError("deleting template: "+name, err)
				ui.SuccessAndExit("Succesfully deleted template", name)
			}

			if len(selectors) != 0 {
				selector := strings.Join(selectors, ",")
				err := client.DeleteTemplates(selector)
				ui.ExitOnError("deleting templates by labels: "+selector, err)
				ui.SuccessAndExit("Succesfully deleted templates by labels", selector)
			}

			ui.Failf("Pass Template name or labels to delete by labels")
		},
	}

	cmd.Flags().StringVarP(&name, "name", "n", "", "unique template name, you can also pass it as first argument")
	cmd.Flags().StringSliceVarP(&selectors, "label", "l", nil, "label key value pair: --label key1=value1")

	return cmd
}
