variable "BASE_IMAGE" {
    default = "nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04"
}

variable "LOLLMS_COMMIT" {
    default = ""
}

group "default" {
    targets = ["lollms-webui"]
}

target "_base" {
    platforms = ["linux/amd64"]
}

target "lollms-webui" {
    name = "lollms-webui-${replace(item.tag, ".", "_")}"
    inherits = ["_base"]
    matrix = {
        item = [
            {
                tag = "latest"
                version = "main"
                update_submodules = "true"
            },
            {
                tag = "9.2"
                version = "v9.2"
                update_submodules = "false"
            }
        ]
    }
    dockerfile = "Dockerfile"
    context = "./lollms-webui"
    tags = [
        "imzacm/lollms-webui:${item.tag}",
        notequal("", LOLLMS_COMMIT) ? "imzacm/lollms-webui:${item.tag}-${LOLLMS_COMMIT}" : ""
    ]
    contexts = {
        base_image = "docker-image://${BASE_IMAGE}"
    }
    args = {
        WEBUI_VERSION = item.version
        UPDATE_SUBMODULES = item.update_submodules
    }
    target = "lollms"
}
