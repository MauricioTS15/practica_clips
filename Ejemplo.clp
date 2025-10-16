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
    (gas-combustible Metano Sulfuro-de-Hidrogeno)
    (ambiente Temperatura Humedad)
    
    ; Alertas y notificaciones
    (sistema-alertas buzzer estado inactivo led-rojo estado inactivo)
    (sistema-notificaciones-medico info-equipo-medico estado inactivo)
    (sistema-actuadores buzzer led-rojo info-equipo-medico)

    (sensor-ultrasonico sensor estado activo)
    (sensor-temperatura-humedad temperatura estado activo humedad estado activo)
    (sensor-casco casco estado activo)
    (protocolo-emergencia protocolo estado activo)

    (concentracion-gas Oxigeno 17)
    (concentracion-gas Metano 50.0)
    (concentracion-gas Monoxido-de-Carbono 15.0)
    (concentracion-gas Dioxido-de-Carbono 0.3)
    (concentracion-gas Sulfuro-de-Hidrogeno 1.0)
    (concentracion-gas Dioxido-de-Nitrogeno 1.0)
    (concentracion-ambiente Temperatura 35.0)
    (concentracion-ambiente Humedad 90.0)
)

(defrule riesgo-termico
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
    (printout t "TE ESTAS SOFOCANDO TONTO " ?nombre " " ?valor crlf)
)