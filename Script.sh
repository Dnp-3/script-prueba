#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Cabecera y cierre
# -----------------------------------------------------------------------------

imprimir_cabecera() {
  echo "=============================================="
  echo "  Orquestador de enumeración Linux"
  echo "  Versión: ${VERSION}"
  echo "  Fecha:   $(date '+%Y-%m-%d %H:%M:%S')"
  echo "=============================================="
  echo
}

imprimir_cierre() {
  echo
  echo "=============================================="
  echo "  Fin de la enumeración"
  echo "=============================================="
}

# -----------------------------------------------------------------------------
# Opciones
# -----------------------------------------------------------------------------

parsear_opciones() {
  while getopts "o:vh" opt; do
    case "$opt" in
      o) OUTPUT_FILE="$OPTARG" ;;
      v) export VERBOSE=1 ;;
      h)
        echo "  -o archivo   Guardar salida en archivo"
        echo "  -v           Modo verbose"
        echo "  -h           Help"
        exit 0
        ;;
      *) exit 1 ;;
    esac
  done
}

# -----------------------------------------------------------------------------
# Fases de enumeración (rellena con tus payloads)
# -----------------------------------------------------------------------------

enumerar_usuarios_y_entorno() {
  echo "=== Usuarios y entorno ==="
  cat /etc/passwd | cut -d: -f1
  echo
}

enumerar_sistema() {
  echo "=== Sistema ==="
  uname -a
  echo
}

enumerar_permisos() {
  echo "=== Permisos (SUID/SGID, writable) ==="
  find / -perm -u=s -type f 2>/dev/null | xargs ls -l
  find / -perm -g=s -type f 2>/dev/null | xargs ls -l
  find / -perm -4000 -type f -exec ls -la {} 2>/dev/null \;
  find / -uid 0 -perm -4000 -type f 2>/dev/null 
  echo
}

enumerar_cron_y_timers() {
  echo "=== Cron y timers ==="
  cat /etc/crontab
  contab -l
  echo
}

enumerar_servicios_y_procesos() {
  echo "=== Servicios y procesos ==="
  systemctl list-units --type=service --all > Servicios.txt 2>/dev/null
  ps aux
  echo
}

enumerar_credenciales_y_datos() {
  echo "=== Credenciales y datos sensibles ==="
  cat /etc/passwd
  cat /etc/shadow 2>/dev/null || echo "No se pudo leer /etc/shadow"
  cat /etc/sudoers 2>/dev/null || echo "No se pudo leer /etc/sudoers"
  echo
}
enumerar_red() {
  echo "=== Configuración de red ==="
  ip addr show
  netstat -tuln
  echo
}

# -----------------------------------------------------------------------------
# Salida
# -----------------------------------------------------------------------------

guardar_salida() {
  if [[ -n "$OUTPUT_FILE" ]]; then
    # Si se usó -o, la salida ya se redirigió desde main
    true
  fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
  parsear_opciones "$@"
  shift $((OPTIND - 1))

  if [[ -n "$OUTPUT_FILE" ]]; then
    exec > >(tee "$OUTPUT_FILE")
  fi

  imprimir_cabecera
  enumerar_usuarios_y_entorno
  enumerar_sistema
  enumerar_permisos
  enumerar_cron_y_timers
  enumerar_servicios_y_procesos
  enumerar_credenciales_y_datos
  enumerar_red
  imprimir_cierre
}

main "$@"
