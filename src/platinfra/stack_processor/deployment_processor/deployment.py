import json
from abc import ABC, abstractmethod

import yaml
from platinfra.enums.cloud_provider import CloudProvider


class AbstractDeployment(ABC):
    """
    Abstract class for deployment
    """

    def __init__(
        self,
        stack_name: str,
        provider: CloudProvider,
        region: str,
        deployment_config: yaml,
    ):
        self.stack_name = stack_name
        self.provider = provider
        self.region = region
        self.deployment_config = deployment_config

    @abstractmethod
    def configure_deployment(self):
        pass

    # TODO: refactor statefile name
    def get_statefile_name(self) -> str:
        return f"tfstate-{self.stack_name}-{self.region}"

    def get_provider_backend(self, provider: CloudProvider) -> json:
        if provider == CloudProvider.AWS:
            return {
                "backend": {
                    "s3": {
                        "bucket": self.get_statefile_name(),
                        "key": "ultimate-mlops-stack",
                        "dynamodb_table": self.get_statefile_name(),
                        "region": self.region,
                        "encrypt": True,
                    }
                }
            }
        # Add other providers here
        # return {}