# Changelog
* Se crea el directorio `.github/workflows` para la integración de automatización.
* Se configura un archivo `.yml` que permite ejecutar procesos automáticos en GitHub Actions al realizar cambios en el repositorio.

### ⚙️ Funcionalidades del pipeline

El pipeline desarrollado tiene como objetivo asegurar la calidad, seguridad y validez del código Terraform mediante tres etapas principales:

1. **Análisis estático del código**

   * Se utiliza la herramienta TFLint para analizar el código Terraform.
   * Permite detectar errores, malas prácticas y problemas de configuración antes del despliegue.

2. **Análisis de seguridad**

comando “terraform validate”.

se crea la rama test para verificar que mediante el pull request se activa el worflows
   * Se implementa la herramienta Checkov para identificar vulnerabilidades en la infraestructura como código.
   * Evalúa configuraciones inseguras, como reglas de red abiertas o malas prácticas en recursos AWS.

3. **Validación de Terraform**

   * Se ejecuta el comando `terraform validate`.
   * Verifica que la sintaxis y estructura del código sean correctas antes de su ejecución.

### ✅ Resultado

* Se logra automatizar el control de calidad del proyecto.
* Cada cambio en el repositorio es validado automáticamente, reduciendo errores en despliegues futuros.
* Se mejora la seguridad y confiabilidad del código Terraform.

se genera en push desde ramas alternas a main para probar el análisis desde la configuración del workflows, y visualizarla en GitHub, en la pestaña actions.
>>>>>>> main

