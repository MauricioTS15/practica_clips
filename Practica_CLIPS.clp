; ============================================================================
;                               BASES DE HECHOS
; ============================================================================
(deffacts hechos_iniciales
    ; Sensores del casco - estado inicial
    (sensor-ultrasonico estado activo distancia 5.0 unidad metros)
    (sensor-temperatura-humedad estado activo temperatura 26.0 humedad 75)
    (sensor-casco estado activo)
    
    ; Límites de seguridad basados en documentos
    (limites-seguridad
        Oxigeno O2 nivel_minimo 19.5 nivel_maximo 23.5
        Metano CH4 nivel_maximo 1.0
        Monoxido-de-Carbono CO nivel_maximo 25
        Dioxido-de-Carbono CO2 nivel_maximo 0.5
        Sulfuro-de-Hidrogeno H2S nivel_maximo 5
        Dioxido-de-Nitrogeno NO2 nivel_maximo 3
        temperatura_maxima 32.0
        humedad_maxima 85.0
        indice_calor_maximo 41.0
    )
    ; Tipos de gases
    (gas Oxigeno)
    (gas-toxico Monoxido-de-Carbono Dioxido-de-Carbono Sulfuro-de-Hidrogeno Nitrógeno)
    (gas-combustible Metano Hidrogeno)
    
    ; Alertas y notificaciones
    (sistema-alertas 
        buzzer estado inactivo 
        led-rojo estado inactivo 
        pantalla-oled estado activo
        info_equipo-medico estado inactiva
    )

    ; Mediciones actuales de gases
    (concentracion-gas Oxigeno 20.9)
    (concentracion-gas Metano 0.2)
    (concentracion-gas Monoxido-de-Carbono 15)
    (concentracion-gas Dioxido-de-Carbono 0.3)
    (concentracion-gas Sulfuro-de-Hidrogeno 1)
    (concentracion-gas Dioxido-de-Nitrogeno 1)
)

; REGLA 1: Evaluación de riesgo por deficiencia de oxígeno
(defrule deficiencia-oxigeno
(limites-seguridad $? ?gas ?simbolo nivel_exposicion ?porcentaje $?)
(gas $? ?gas $?)

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

