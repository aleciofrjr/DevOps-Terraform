variable "instance_name" {
    description = "Nome instância EC2"
    type        = string
    default     = "Server_Nginx"
}

variable "image_name" {
    description = "Imagem da instância EC2"
    type        = string
    default     = "ami-0892d3c7ee96c0bf7"
}
