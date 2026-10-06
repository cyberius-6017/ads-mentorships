import 'package:flutter/material.dart';

// Este archivo junta el "uniforme" de la app: los colores del equipo, los
// dos botones (naranja y azul) y el estilo de las cajas del formulario.
// Así main.dart no se llena de colores y tamaños, y si algo cambia, se
// cambia aquí una sola vez.

// ---------------------------------------------------------------------
// LOS COLORES DEL EQUIPO, EN UN SOLO LUGAR
// ---------------------------------------------------------------------
// Son los mismos colores de ads.team6017.com, para que la app se sienta
// parte de la familia Cyberius. Escribirlos una vez (y no "0xFF006EB6"
// regado por todos lados) es la misma idea que sacar el botón a su
// propio archivo: si el color cambia, se cambia aquí.
const Color kAzul = Color(0xFF006EB6); // azul Cyberius: acción principal
const Color kFondo = Color(0xFFC9EDFF); // azul claro: fondo de la pantalla
const Color kNaranja = Color(0xFFF96815); // naranja: los botones de contar
const Color kTinta = Color(0xFF003D63); // azul muy oscuro: el texto
const Color kTintaSuave = Color(0xFF46708F); // azul apagado: texto secundario
// Los botones naranjas llevan texto casi negro y no blanco: el blanco
// sobre naranja se lee mal bajo el sol de las gradas.
const Color kTintaNaranja = Color(0xFF12293D);

// ---------------------------------------------------------------------
// BOTÓN NARANJA: el de contar
// ---------------------------------------------------------------------
// Un ElevatedButton con ícono, ya vestido de naranja. Igual que el
// CounterButton, no decide qué texto lleva ni qué hace al tocarlo: eso
// se lo pasa quien lo usa.
class BotonNaranja extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const BotonNaranja({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: kNaranja,
        foregroundColor: kTintaNaranja,
        elevation: 0,
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
    );
  }
}

// ---------------------------------------------------------------------
// BOTÓN AZUL: el de guardar
// ---------------------------------------------------------------------
// Mismo molde que el naranja, pero azul. Los naranjas se tocan muchas
// veces durante el match; el azul se toca una sola vez, al final, y
// conviene que no se confunda con los otros.
class BotonAzul extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const BotonAzul({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAzul,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

// ---------------------------------------------------------------------
// LA CAJITA DE LOS CAMPOS DEL FORMULARIO
// ---------------------------------------------------------------------
// No es un widget: es una función que regresa la "decoración" (fondo,
// borde, esquinas) de una caja de formulario. La usan el TextField y el
// dropdown, y por eso los dos se ven exactamente iguales.
//
// hintText y prefixText llevan `?` porque son opcionales: el dropdown no
// usa ninguno de los dos.
InputDecoration decoracionCampo({String? hintText, String? prefixText}) {
  return InputDecoration(
    hintText: hintText,
    prefixText: prefixText,
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(color: kTintaSuave),
    prefixStyle: const TextStyle(
      color: kTintaSuave,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0x33006EB6), width: 1.5),
    ),
    // El borde grueso azul marca dónde está el cursor. Sin esto, con el
    // teclado abierto no se sabe qué campo se está llenando.
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kAzul, width: 2),
    ),
  );
}
