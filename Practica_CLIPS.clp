; ============================================================================
;                               BASES DE HECHOS
; ============================================================================
(deffacts hechos_iniciales
    ; Límites de seguridad basados en documentos
    (limites-seguridad
        Oxigeno O2 nivel_minimo 19.5 nivel_maximo 23.5
        Metano CH4 nivel_minimo 0.5 nivel_maximo 1.0 
        Monoxido-de-Carbono CO nivel_minimo 25.0 nivel_maximo 50.0
        Dioxido-de-Carbono CO2 nivel_minimo 0.5 nivel_maximo 1.0
        Sulfuro-de-Hidrogeno H2S nivel_minimo 1.0 nivel_maximo 5.0
        Oxido-de-Nitrogeno NO2 nivel_minimo 1.0 nivel_maximo 20.0
        Temperatura T nivel_minimo 15.0 nivel_maximo 32.0
        Humedad H nivel_minimo 30.0 nivel_maximo 85.0
    )
    ; Tipos de gases
    (gas Oxigeno)
    (gas-toxicos Monoxido-de-Carbono Dioxido-de-Carbono Sulfuro-de-Hidrogeno Oxido-de-Nitrogeno)
    (gas-combustible Metano Sulfuro-de-Hidrogeno)
    (ambiente Temperatura Humedad)
    
    ; Alertas y notificaciones
    (sistema-alertas buzzer estado inactivo led-rojo estado inactivo)
    (sistema-notificaciones-medico info-equipo-medico estado inactivo)
    (sistema-actuadores buzzer led-rojo info-equipo-medico)

    ; Estado de los sensores principales
    (sensor-ultrasonico sensor estado activo)
    (sensor-temperatura-humedad temperatura estado activo humedad estado activo)
    (sensor-casco casco estado activo)
    (protocolo-emergencia protocolo estado activo)

    ; Detección del nivel de gases
    (concentracion-gas Oxigeno 20)
    (concentracion-gas Metano 0.70)
    (concentracion-gas Monoxido-de-Carbono 30.0)
    (concentracion-gas Dioxido-de-Carbono 0.70)
    (concentracion-gas Sulfuro-de-Hidrogeno 1.0)
    (concentracion-gas Dioxido-de-Nitrogeno 10.0)
    (concentracion-ambiente Temperatura 16.0)
    (concentracion-ambiente Humedad 31.0)
	; Detección de aumento del Metano (Historial)
	(historial-gas Metano 0.5 10:00)

)

; ============================================================================
;                     HECHOS INDEPENDIENTES PARA ACTIVACIÓN
; ============================================================================
; Prioridad de reglas
; set-strategy <breadth>
; set-strategy <breadth>
; Mediciones actuales de gases
;     (assert
;         (concentracion-gas Metano 0.7)
;         (concentracion-gas Sulfuro-de-Hidrogeno 60.0)
;         (concentracion-gas Oxigeno 17.0)
;         (concentracion-gas Monoxido-de-Carbono 80.0)
;         (concentracion-ambiente Temperatura 33.0)
; )
; Sensores del casco - estado inicial
;      (assert
;         (sensor-ultrasonico ultrasonico estado inactivo)
;         (sensor-temperatura-humedad temperatura estado inactivo humedad estado inactivo)
;         (sensor-casco casco estado inactivo)
;         (protocolo-emergencia protocolo estado inactivo)
; )
; ============================================================================
;                     REGLAS QUE INICIAN EL PROGRAMA
; ============================================================================
; REGLA 1: Establecer el inicio del programa
(defrule inicio-casco
    (sensor-ultrasonico sensor estado activo)
    (sensor-temperatura-humedad temperatura estado activo humedad estado activo)
    (sensor-casco casco estado activo)
    =>
    (assert(sistema-inicio monitoreo estado activo))
    (printout t "1-SISTEMA DE MONITOREO ACTIVADO" crlf)
)

; REGLA 2: Establecer el inicio del protocolo de emergencia
(defrule inicio-emergencia
    (protocolo-emergencia protocolo estado activo)
    =>
    (assert(sistema-emergencia emergencia estado inactivo))
    (printout t "2-PROTOCOLO DE EMERGENCIA ACTIVADO" crlf)
)
; ============================================================================
;                               REGLAS
; ============================================================================
;REGLA 1: Evaluación de riesgo por deficiencia de oxígeno, 
;avisa cuando el valor es menor o mayor que el mínimo.
(defrule deficiencia-oxigeno
    (sistema-inicio monitoreo estado activo)
    (concentracion-gas ?nombre ?valor_medido)
    (limites-seguridad $? ?nombre ?simbolo nivel_minimo ?minimo nivel_maximo ?maximo $?)
    (gas ?nombre)
    (or
        (test (> ?minimo ?valor_medido ))
        (test (< ?maximo ?valor_medido ))
    )
    ?ind1 <- (sistema-alertas $?antes ?tipo estado inactivo $?despues)
    (sistema-actuadores $? ?tipo $?)
    =>
    (retract ?ind1)
	(assert (alerta aviso-trabajador))
    (assert(sistema-alerta-activo $?antes ?tipo estado activo $?despues))
    (printout t "3-ALERTA OXIGENO: " ?nombre " = " ?valor_medido  crlf)
)
; REGLA 2: Evaluación de riesgo por gases combustibles
;1.El Metano es inflamable, mezclado con aire en
;concentraciones entre el 5% y el 10% puede formar mezclas explosivas
;lo que puede llevar a producir Hidrogeno como subproducto.
;2.El Hidrogeno es altamente inflamable, mezclado con aire en
;concentraciones entre el 4% y el 76% puede formar mezclas explosivas.
;3.El polvo puede acumularse en suspensiones en el aire, creando 
;un riesgo de explosiones de polvo.
;Conflicto: Esta regla es una agrupación de 2 reglas que crean un conflicto.
;La estrategia de ejecutación del programa lo ejecutará según el primero que llegue
;a la cola de ejecución

;Avisa al trabajador activando otra alerta de sistema-alertas
(defrule gases-combustibles-avisa-trabajador
    (sistema-inicio monitoreo estado activo)
    (limites-seguridad $? ?nombre ?simbolo nivel_minimo ?minimo nivel_maximo ?maximo $?)
    (gas-combustible $? ?nombre $?)
    (concentracion-gas ?nombre ?valor_medido)
    (test (> ?valor_medido ?maximo))
    =>
    (assert (alerta aviso-trabajador))
    (printout t "4-AVISO AL TRABAJADOR: Esta en zona de altos gases de combustión" crlf)
)

;Avisa al medico que el trabajador esta en zona peligrosa
(defrule gases-combustibles-aviso-medico
    (sistema-inicio monitoreo estado activo)
    (limites-seguridad $? ?nombre ?simbolo nivel_minimo ?minimo nivel_maximo ?maximo $?)
    (gas-combustible $? ?nombre $?)
    (concentracion-gas ?nombre ?valor_medido)
    (test (> ?valor_medido ?maximo))
    =>
    (assert (alerta aviso-medico))
    (printout t "5-AVISO AL MEDICO: el trabajador esta en zona de altos gases de combustión" crlf)
)


; REGLA 3: Evaluación de condiciones ambientales extremas
;Dependiendo de la temperatura en relacion con la humedad
;una persona tendra diferentes riesgos térmicos
(defrule riesgo-termico
	(sistema-inicio monitoreo estado activo)
    (limites-seguridad $? ?nombre ?simbolo nivel_minimo ?minimo nivel_maximo ?maximo $?)
    (ambiente $? ?var $?)
    (concentracion-ambiente ?nombre ?valor)
    (or
        (and
            (test(eq ?nombre Temperatura))
            (test(> ?valor ?maximo))
        )
        (and
            (test(eq ?nombre Humedad))
            (test(> ?valor ?maximo))
        )
    )
    (not (mensaje-mostrado ?nombre ?valor))
    =>
    (assert (mensaje-mostrado ?nombre ?valor))
	(assert (alerta aviso-trabajador))
    (printout t "6-TE ESTAS SOFOCANDO " ?nombre " " ?valor crlf)
)

; REGLA 4: Evaluación de riesgo por múltiples gases tóxicos
(defrule gases-toxicos
    (sistema-inicio monitoreo estado activo)
    (limites-seguridad $? ?nombre ?simbolo nivel_minimo ?minimo nivel_maximo ?maximo $?)
    (gas-toxicos $? ?nombre $?)
    (concentracion-gas ?nombre ?valor_medido)
    (test (> ?valor_medido ?maximo))
    =>
    (assert (alerta gases_alta_toxicidad))
    (assert (alerta aviso-trabajador))
    (printout t "7-Aviso al trabajador que esta en zona de altos gases de toxicidad" crlf)
)

; REGLA 5: Evaluación de tendencia peligrosa
(defrule tendencia-peligrosa-incremento-gases
	(sistema-inicio monitoreo estado activo)
    ; Detecta cuando los gases están aumentando rápidamente
    (concentracion-gas ?gas ?valor-actual)
    ?historial <- (historial-gas ?gas ?valor-anterior ?timestamp)
    (limites-seguridad $? ?gas ?simbolo nivel_minimo ?min nivel_maximo ?max $?)
    (test 
        (and
            (> ?valor-actual ?valor-anterior)
            (> (/ (- ?valor-actual ?valor-anterior) ?valor-anterior) 0.3)  ; 30% de aumento
            (> ?valor-actual ?min)  ; Ya está por encima del mínimo seguro
        )
    )
    =>
	(assert (alerta aviso-trabajador))
    (printout t
        "8-ALERTA: Incremento rápido de " ?gas " - "?valor-anterior " -> " ?valor-actual " ("
		(* (/ (- ?valor-actual ?valor-anterior) ?valor-anterior) 100)"%)" crlf)
)

; REGLA 6: Detección de fallos en cascada
(defrule fallo-sensores
	(sistema-inicio monitoreo estado activo)
	(or
        (sensor-ultrasonico ?tipo estado ?estado)
        (sensor-temperatura-humedad $? ?tipo estado ?estado $?)
        (sensor-casco ?tipo estado ?estado)
	)
    (test (eq ?estado inactivo))
    =>
    (printout t "9-EMERGENCIA: El sensor " ?tipo " esta fallando. - Sistema de monitoreo comprometido." crlf)
    (assert (activar-protocolo-reserva))
    (assert (notificar-supervisor fallo-sensores-multiple))
)

; ============================================================================
;                          ACTIVACIÓN DEL SISTEMA MEDICO
; ============================================================================

;Activa sistema-notificaciones-medico sólo cuando haya aviso-medico
(defrule activar-notificaciones-medico-por-aviso-medico
    (sistema-inicio monitoreo estado activo)
	(alerta aviso-medico)
    ?n <- (sistema-notificaciones-medico $?antes ?tipo estado inactivo $?despues)
    =>
    (retract ?n)
    (assert (sistema-notificaciones-medico $?antes ?tipo estado activo $?despues))
    (printout t "-> SISTEMA-NOTIFICACIONES-MEDICO ACTIVADO" crlf)
)

