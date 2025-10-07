;Base de hechos iniciales
(deffacts atmosfera_mina
    ;Los siguientes son los límites máximos permitidos de gases en la atmósfera de la mina:
    ;Nitrógeno: 76% - 80%
    ;Oxígeno: 19,5% - 23,5%
    ;Grisú (metano): < 1% vol.
    ;Hidrógeno: < 0,1% vol.
    ;Óxidos nitrosos: < 25 ppm
    ;Anhídrido carbónico: < 0,5%
    ;Monóxido de carbono: < 50 ppm
    ;Sulfuro de hidrógeno: < 10 ppm
    ;Anhídrido sulfuroso: < 2 ppm
    (concentracion_gases 
        Nitrógeno N2 nivel_exposicion 70
        Oxigeno O2 nivel_exposicion 20.9
        Metano CH4 nivel_exposicion 1.5
        Hidrogeno H2 nivel_exposicion 1
        Monóxido-de-Carbono CO nivel_exposicion 25
        Dióxido-de-Carbono CO2 nivel_exposicion 0,5
        Sulfuro-de-Hidrogeno H2S nivel_exposicion 2
    )
    ;Hecho que nos ayudara a delimitar los hechos anteriores
    (tipo_gases
        Nitrógeno 
        Oxigeno 
        Metano 
        Monóxido-de-Carbón 
        Dióxido-de-Carbón 
        Sulfuro-de-Hidrogeno 
        Dióxido-de-Nitrógeno
    )
    ;temperatura de <25º        -> Baja
    ;temperatura de 25º y 28º   -> Normal
    ;temperatura de 28º y 32º   -> Alta
    ;temperatura de >32º       -> Muy alta
    (temperatura Baja Normal Alta Muy-Alta)

    ;humedad de <70%        -> Baja
    ;humedad de 70% y 85%   -> Normal
    ;humedad de 85% y 90%   -> Alta
    ;humedad de >90%        -> Muy alta
    (humedad Baja Normal Alta Muy-Alta)
    (sensor_ultrasonico )
    (polvo_carbon )
    (roca )
    (equipos )
)

;Regla de EXPLOCION
;1.El Metano es inflamable, mezclado con aire en
;concentraciones entre el 5% y el 10% puede formar mezclas explosivas
;lo que puede llevar a producir Hidrogeno como subproducto.
;2.El Hidrogeno es altamente inflamable, mezclado con aire en
;concentraciones entre el 4% y el 76% puede formar mezclas explosivas.
;3.El polvo puede acumularse en suspensiones en el aire, creando 
;un riesgo de explosiones de polvo.

;Regla de RIESGO TÉRMICO
;Dependiendo de la temperatura en relacion con la humedad
;una persona tendra diferentes riesgos térmicos

;Regla NIVEL DE EXPOSICIÓN A UN GAS

;Regla MEZCLA DE GASES

;Regla SEGURIDAD DE LAS MÁQUINAS, HERRAMIENTAS, EQUIPOS