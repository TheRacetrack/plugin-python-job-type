from __future__ import annotations


class Plugin:
    def job_types(self) -> dict[str, list[str]]:
        """
        Job types provided by this plugin
        :return dict of job type name (with version) -> list of images: dockerfile template path relative to a jobtype directory
        """
        return {
            f'python3:{self.plugin_manifest.version}': ['job-template.Dockerfile'],
        }
