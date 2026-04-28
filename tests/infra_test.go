package test

import (
	"fmt"
	"testing"
	"time"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAzureDevOpsProject(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	rgName := terraform.Output(t, terraformOptions, "final_resource_group_name")
	publicIPs := terraform.OutputList(t, terraformOptions, "adresse_ip_vm")

	assert.NotEmpty(t, rgName, "Le nom du Resource Group ne doit pas être vide")
	assert.Equal(t, 2, len(publicIPs), "On devrait avoir exactement 2 IPs publiques")
	assert.NotEmpty(t, publicIPs[0], "L'IP de la VM-0 ne doit pas être vide")

	t.Log("Attente de 30 secondes pour le boot des VMs...")
	time.Sleep(30 * time.Second)

	for _, ip := range publicIPs {
		t.Logf("Tentative de ping sur %s...", ip)
		
		cmd := shell.Command{
			Command: "ping",
			Args:    []string{"-c", "3", ip},
		}
		
		_, err := shell.RunCommandAndGetOutputE(t, cmd)

		assert.NoError(t, err, fmt.Sprintf("La VM avec l'IP %s ne répond pas au ping", ip))
	}

	t.Logf("Succès ! L'infrastructure dans le RG : %s est fonctionnelle et a été détruite", rgName)
}