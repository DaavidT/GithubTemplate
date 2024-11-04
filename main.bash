# Asegurar codificación UTF-8 en PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Verifica si la rama DavidTalavera existe
$branchDavidTalavera = git branch --list | Select-String -Pattern "david-t"
if (-not $branchDavidTalavera) {
    Write-Host "La rama david-t no existe. Abortando."
    exit 1
}

# Verifica si la rama main existe
$branchMain = git branch --list | Select-String -Pattern "main"
if (-not $branchMain) {
    Write-Host "La rama main no existe. Abortando."
    exit 1
}

# Checkout a la rama DavidTalavera
git checkout david-t

# Pull de la rama DavidTalavera
git pull origin david-t

# Obtener los últimos cambios de la rama main
git fetch origin main

# Resetear la rama DavidTalavera al último commit de main
git reset --soft origin/main

# Extraer el último mensaje de commit
$last_commit_message = git log -1 --pretty=%B -Raw

# Imprimir el mensaje de commit para verificar el contenido
Write-Host "Mensaje de commit: '$last_commit_message'"

# Buscar el texto que contiene la palabra "Versión"
if ($last_commit_message -like "*Versión*") {
    # Dividir el mensaje por espacios
    $commit_parts = $last_commit_message.Split(" ")

    # Buscar la palabra "Versión" y obtener el siguiente valor (la versión)
    $index = [Array]::IndexOf($commit_parts, "Versión")
    if ($index -ge 0 -and $commit_parts.Length -gt ($index + 1)) {
        # La versión está inmediatamente después de la palabra "Versión"
        $version = $commit_parts[$index + 1]
        Write-Host "Versión encontrada: $version"

        # Extraer los números de la versión y aumentar el último número
        $parts = $version -split '\.'
        $parts[-1] = [int]$parts[-1] + 1  # Incrementar el último número
        $new_version = ($parts -join '.')
        
        # Crear un nuevo commit con la nueva versión
        git commit --allow-empty -m "Versión $new_version (Unión de main y david-t)"
        git push origin david-t
        
        Write-Host "Fusión completada y versión actualizada a: Versión $new_version"
    } else {
        Write-Host "No se encontró una versión válida después de 'Versión'."
    }
} else {
    Write-Host "No se encontró el texto 'Versión' en el mensaje de commit."
}
