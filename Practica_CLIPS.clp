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
    (gas-toxico Monoxido-de-Carbono Dioxido-de-Carbono Sulfuro-de-Hidrogeno Oxido-de-Nitrogeno)
    (gas-combustible Metano Hidrogeno)
    (ambiente Temperatura Humedad)
    
    ; Alertas y notificaciones
    (sistema-alertas 
        buzzer estado inactivo 
        led-rojo estado inactivo 
        pantalla-oled estado activo
        info_equipo-medico estado inactiva 
    )

    ; Mediciones actuales de gases
    (concentracion-gas Oxigeno 17)
    (concentracion-gas Metano 0.2)
    (concentracion-gas Monoxido-de-Carbono 15.0)
    (concentracion-gas Dioxido-de-Carbono 0.3)
    (concentracion-gas Sulfuro-de-Hidrogeno 1.0)
    (concentracion-gas Dioxido-de-Nitrogeno 1.0)
    (concentracion-ambiente Temperatura 15.0)
    (concentracion-ambiente Humedad 30.0)
)

; ============================================================================
;                     HECHOS INDEPENDIENTES PARA ACTIVACIÓN
; ============================================================================
; Sensores del casco - estado inicial
    ; (assert(sensor-ultrasonico estado activo distancia 5.0 unidad metros))
    ; (assert(sensor-temperatura-humedad estado activo temperatura 26.0 humedad 75))
    ; (assert(sensor-casco estado activo))
; ============================================================================
;                               REGLAS
; ============================================================================
; REGLA 0: Recoger valores

; REGLA 1: Evaluación de riesgo por deficiencia de oxígeno, avisa cuando el valor es menor que el minimo
(defrule deficiencia-oxigeno
    (concentracion-gas ?nombre ?valor_medido)
    (limites-seguridad $? ?nombre ?simbolo nivel_minimo ?minimo nivel_maximo ?maximo $?)
    (gas ?nombre)
    (or
        (test (> ?minimo ?valor_medido ))
        (test (< ?maximo ?valor_medido ))
    )
    =>
    (assert (alerta oxigeno))
)



; REGLA 2: Evaluación de riesgo por gases combustibles
;1.El Metano es inflamable, mezclado con aire en
;concentraciones entre el 5% y el 10% puede formar mezclas explosivas
;lo que puede llevar a producir Hidrogeno como subproducto.
;2.El Hidrogeno es altamente inflamable, mezclado con aire en
;concentraciones entre el 4% y el 76% puede formar mezclas explosivas.
;3.El polvo puede acumularse en suspensiones en el aire, creando 
;un riesgo de explosiones de polvo.

; REGLA 3: Evaluación de riesgo térmico por índice de calor
;Dependiendo de la temperatura en relacion con la humedad
;una persona tendra diferentes riesgos térmicos

; REGLA 4: Evaluación de riesgo por múltiples gases tóxicos

; REGLA 5: Evaluación de riesgo combinado temperatura y humedad alta

