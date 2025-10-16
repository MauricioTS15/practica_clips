;; =============================================
;; SISTEMA EXPERTO PARA MONITOREO MINERO
;; =============================================

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
        pantalla-oled estado inactivo
        info_equipo-medico estado inactivo 
    )

    ; Mediciones actuales de gases
    (concentracion-gas Oxigeno 17)
    (concentracion-gas Metano 0.2)
    (concentracion-gas Monoxido-de-Carbono 15.0)
    (concentracion-gas Dioxido-de-Carbono 0.3)
    (concentracion-gas Sulfuro-de-Hidrogeno 1.0)
    (concentracion-gas Oxido-de-Nitrogeno 1.0)
    (concentracion-ambiente Temperatura 15.0)
    (concentracion-ambiente Humedad 30.0)
)

;; =============================================
;; 1. CASOS DE USO - HECHOS INDEPENDIENTES
;; =============================================

(defrule activar-sistema-casco
    (sensor-casco estado activo)
    (sensor-temperatura-humedad estado activo)
    (sensor-ultrasonico estado activo)
    =>
    (printout t "=== SISTEMA DE CASCO INTELIGENTE ACTIVADO ===" crlf)
    (printout t "Todos los sensores operativos" crlf)
    (assert (iniciar-monitoreo-continuo))
    (assert (verificar-sensores)))

(defrule activar-protocolo-emergencia
    (protocolo-emergencia tipo ?tipo)
    =>
    (printout t "=== PROTOCOLO DE EMERGENCIA ACTIVADO: " ?tipo " ===" crlf)
    (assert (activar-sistema-alertas-completo))
    (assert (notificar-equipo-medico)))

;; =============================================
;; 2. REGLAS GENÉRICAS CON COMODINES
;; =============================================

;; REGLA 1: Evaluación de niveles mínimos peligrosos
(defrule evaluar-nivel-minimo-peligroso
    (concentracion-gas ?gas ?valor)
    (limites-seguridad ?gas ?codigo nivel_minimo ?minimo nivel_maximo ?maximo)
    (test (< ?valor ?minimo))
    =>
    (assert (alerta tipo nivel-minimo nivel critico parametro ?gas valor ?valor limite ?minimo))
    (assert (activar-buzzer frecuencia alta))
    (assert (activar-led-rojo color rojo))
    (printout t "ALERTA NIVEL MÍNIMO: " ?gas " = " ?valor " < " ?minimo crlf))

;; REGLA 2: Evaluación de niveles máximos peligrosos
(defrule evaluar-nivel-maximo-peligroso
    (concentracion-gas ?gas ?valor)
    (limites-seguridad ?gas ?codigo nivel_minimo ?minimo nivel_maximo ?maximo)
    (test (> ?valor ?maximo))
    =>
    (assert (alerta tipo nivel-maximo nivel critico parametro ?gas valor ?valor limite ?maximo))
    (assert (activar-buzzer frecuencia alta))
    (assert (activar-led-rojo color rojo-parpadeante))
    (printout t "ALERTA NIVEL MÁXIMO: " ?gas " = " ?valor " > " ?maximo crlf))

;; REGLA 3: Evaluación de condiciones ambientales extremas
(defrule evaluar-condiciones-ambientales-extremas
    (concentracion-ambiente ?parametro ?valor)
    (limites-seguridad ?parametro ?codigo nivel_minimo ?minimo nivel_maximo ?maximo)
    (test (or (< ?valor ?minimo) (> ?valor ?maximo)))
    =>
    (assert (alerta tipo ambiental nivel alto parametro ?parametro valor ?valor))
    (assert (activar-buzzer frecuencia media))
    (assert (activar-pantalla-oled mensaje ?parametro))
    (printout t "ALERTA AMBIENTAL: " ?parametro " = " ?valor crlf))

;; REGLA 4: Detección de múltiples gases tóxicos en niveles peligrosos
(defrule deteccion-multiples-gases-toxicos
    (concentracion-gas ?gas1 ?valor1)
    (concentracion-gas ?gas2 ?valor2)
    (gas-toxico ?gas1)
    (gas-toxico ?gas2)
    (limites-seguridad ?gas1 ?codigo1 nivel_minimo ?min1 nivel_maximo ?max1)
    (limites-seguridad ?gas2 ?codigo2 nivel_minimo ?min2 nivel_maximo ?max2)
    (test (and (neq ?gas1 ?gas2) (> ?valor1 ?max1) (> ?valor2 ?max2)))
    =>
    (assert (alerta-multiple tipo gases-toxicos nivel critico gases ?gas1 ?gas2))
    (assert (activar-buzzer frecuencia maxima))
    (assert (activar-led-rojo color rojo-parpadeante))
    (assert (activar-info-equipo-medico estado activo))
    (printout t "ALERTA MÚLTIPLE GASES TÓXICOS: " ?gas1 " + " ?gas2 crlf))

;; REGLA 5: Evaluación de gases combustibles en nivel explosivo
(defrule evaluar-gas-combustible-explosivo
    (concentracion-gas ?gas ?valor)
    (gas-combustible ?gas)
    (limites-seguridad ?gas ?codigo nivel_minimo ?minimo nivel_maximo ?maximo)
    (test (> ?valor ?maximo))
    =>
    (assert (alerta tipo gas-combustible nivel critico parametro ?gas valor ?valor))
    (assert (activar-buzzer frecuencia maxima))
    (assert (activar-led-rojo color rojo-parpadeante))
    (assert (activar-pantalla-oled mensaje "GAS COMBUSTIBLE"))
    (printout t "ALERTA GAS COMBUSTIBLE EXPLOSIVO: " ?gas " = " ?valor crlf))

;; =============================================
;; 3. CONFLICTO DE REGLAS - ESTRATEGIA DE RESOLUCIÓN
;; =============================================

;; REGLA 6: Priorización de alertas críticas (CONFLICTO)
(defrule priorizar-alertas-criticas
    ?a1 <- (activar-buzzer frecuencia maxima)
    ?a2 <- (activar-buzzer frecuencia ?freq)
    (test (neq ?freq 'maxima))
    =>
    (retract ?a2)
    (printout t "PRIORIZACIÓN: Alerta MÁXIMA tiene precedencia sobre " ?freq crlf)
    (assert (activar-buzzer frecuencia ?freq prioridad baja)))

;; =============================================
;; REGLAS DE CONTROL DE ACTUADORES
;; =============================================

(defrule controlar-buzzer
    (activar-buzzer frecuencia ?freq)
    ?s <- (sistema-alertas buzzer estado inactivo ?resto)
    =>
    (retract ?s)
    (assert (sistema-alertas buzzer estado activo frecuencia ?freq ?resto))
    (printout t "BUZZER: Activado [Frecuencia: " ?freq "]" crlf))

(defrule controlar-led-rojo
    (activar-led-rojo color ?color)
    ?s <- (sistema-alertas led-rojo estado inactivo ?resto)
    =>
    (retract ?s)
    (assert (sistema-alertas led-rojo estado activo color ?color ?resto))
    (printout t "LED ROJO: Activado [Color: " ?color "]" crlf))

(defrule controlar-pantalla-oled
    (activar-pantalla-oled mensaje ?msg)
    ?s <- (sistema-alertas pantalla-oled estado inactivo ?resto)
    =>
    (retract ?s)
    (assert (sistema-alertas pantalla-oled estado activo mensaje ?msg ?resto))
    (printout t "PANTALLA OLED: " ?msg crlf))

(defrule controlar-info-equipo-medico
    (activar-info-equipo-medico estado activo)
    ?s <- (sistema-alertas info_equipo-medico estado inactivo ?resto)
    =>
    (retract ?s)
    (assert (sistema-alertas info_equipo-medico estado activo ?resto))
    (printout t "EQUIPO MÉDICO: Notificado" crlf))

;; =============================================
;; REGLAS DE MONITOREO CONTINUO
;; =============================================

(defrule iniciar-monitoreo-continuo
    (iniciar-monitoreo-continuo)
    =>
    (printout t "--- INICIANDO MONITOREO CONTINUO ---" crlf)
    (assert (evaluar-condiciones-ambientales))
    (assert (verificar-niveles-gases)))

(defrule evaluar-condiciones-ambientales
    (evaluar-condiciones-ambientales)
    =>
    (printout t "--- EVALUANDO CONDICIONES AMBIENTALES ---" crlf)
    (assert (verificar-parametro-ambiente Temperatura))
    (assert (verificar-parametro-ambiente Humedad)))

(defrule verificar-niveles-gases
    (verificar-niveles-gases)
    =>
    (printout t "--- VERIFICANDO NIVELES DE GASES ---" crlf)
    (assert (verificar-gas Oxigeno))
    (assert (verificar-gas Metano))
    (assert (verificar-gas Monoxido-de-Carbono))
    (assert (verificar-gas Dioxido-de-Carbono))
    (assert (verificar-gas Sulfuro-de-Hidrogeno))
    (assert (verificar-gas Oxido-de-Nitrogeno)))

(defrule verificar-sensores
    (verificar-sensores)
    =>
    (printout t "--- VERIFICANDO ESTADO DE SENSORES ---" crlf)
    (assert (sensor-operativo sensor-casco))
    (assert (sensor-operativo sensor-temperatura-humedad))
    (assert (sensor-operativo sensor-ultrasonico)))