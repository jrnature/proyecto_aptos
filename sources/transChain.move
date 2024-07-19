// Para estudiar el funcionamiento del Global Storage vamos a hacer un programa completo.
// Integraremos la mayoria de las cosas que se han visto hasta ahora , por lo que es necesario que no hayas saltado los temas anteriores. 
// El modulo es simplemente un contador. Almacenaremos un numero entero y tendremos una funcion para incrementarlo.
module cuenta::transChain {
 //   use std::signer; // Global Storage trabaja sobre el signer y address como vimos anteriormente.
    use std::signer::address_of;
 //   use std::debug::print;
//    use std::string_utils::debug_string;
    use std::string::{String};
 //   use std::option::{Option};
    //use std::bool::{};
    //use std::address;
    use aptos_std::table::{Self, Table};

    const EYA_INICIALIZADO: u64 = 1;
    const ENO_INICIALIZADO: u64 = 2;
    const EREGISTRO_NO_EXISTE: u64 = 3;
    const EREGISTRO_YA_EXISTE: u64 = 4;
  
    struct IdSolicitud has key,  drop, copy { valor: u64 } 
    struct IdDependencia has key,  drop, copy { valor: u64 }
    struct IdEnlace has key,  drop, copy { valor: u64 }
    struct IdRespuesta has key,  drop, copy { valor : u64}

    struct Solicitud has drop, copy ,store{
        solicitante : String,
        correo : String,
        idDependencia : u64,
        fecha : String,
        atendido : bool
    }

    struct Dependencia has drop, copy,store {
        nombre:String,
        direccion:String,
        telefono:String,
        correo:String,
    }

    struct Enlace has drop,copy,store{
        nombre : String,
        cargo : String, 
        idDependencia : u64,
        correo : String
    }

    struct Respuesta has drop,copy,store{
        idSolicitud: u64,
        informacion: String,
        anexos : String,
        fecha  : String,
        responsable : address,
        validacion : bool,
        validador : address
    }

    struct Dependencias has key{
        dependencias:Table<IdDependencia,Dependencia>
    }
    struct Enlaces has key{
        enlaces:Table<IdEnlace,Enlace>
    }
    struct Solicitudes has key{
        solicitudes:Table<IdSolicitud,Solicitud>
    }
    struct Respuestas has key{
        respuestas:Table<IdRespuesta,Respuesta>
    }

    public entry fun inicializar(cuenta: &signer) {
        assert!(!exists<Dependencias>(address_of(cuenta)), EYA_INICIALIZADO); 
        move_to(cuenta, Dependencias {
            dependencias: table::new<IdDependencia,Dependencia>(),
        });
        assert!(!exists<Enlaces>(address_of(cuenta)), EYA_INICIALIZADO); 
        move_to(cuenta, Enlaces {
            enlaces: table::new<IdEnlace,Enlace>(),
        });
        assert!(!exists<Solicitudes>(address_of(cuenta)), EYA_INICIALIZADO); 
        move_to(cuenta, Solicitudes {
            solicitudes: table::new<IdSolicitud,Solicitud>(),
        });
        assert!(!exists<Respuestas>(address_of(cuenta)), EYA_INICIALIZADO); 
        move_to(cuenta, Respuestas {
            respuestas: table::new<IdRespuesta,Respuesta>(),
        })
    }

    public entry fun add_dependencia(
        cuenta:address,
        nombre:String,
        direccion:String,
        telefono:String,
        correo:String,
        idDependencia: u64
    ) acquires Dependencias {
        let valor=idDependencia;
        assert!(exists<Dependencias>(cuenta), ENO_INICIALIZADO);

        let dependencias = borrow_global_mut<Dependencias>(cuenta);
        assert!(!table::contains(&dependencias.dependencias, IdDependencia { valor }), EREGISTRO_YA_EXISTE);

        table::add(&mut dependencias.dependencias, IdDependencia {
            valor,
        }, Dependencia {
            nombre,
            direccion,
            telefono,
            correo,
        });
    }

    public entry fun add_enlace(
        cuenta:address,
        nombre : String,
        cargo : String, 
        idDependencia : u64,
        correo : String,
        idEnlace: u64
    ) acquires Dependencias, Enlaces {
        let valor=idDependencia;
        assert!(exists<Enlaces>(cuenta), ENO_INICIALIZADO);

        let dependencias = borrow_global_mut<Dependencias>(cuenta);
        assert!(table::contains(&dependencias.dependencias, IdDependencia { valor }), EREGISTRO_NO_EXISTE);
        valor=idEnlace;

        let enlaces = borrow_global_mut<Enlaces>(cuenta);
        assert!(!table::contains(&enlaces.enlaces, IdEnlace { valor }), EREGISTRO_YA_EXISTE);

        table::add(&mut enlaces.enlaces, IdEnlace {
            valor,
        }, Enlace {
            nombre,
            cargo, 
            idDependencia,
            correo
        });
    }

    public entry fun add_Solicitud(
        cuenta:address,
        solicitante : String,
        correo : String,
        idDependencia : u64,
        fecha : String,
        atendido : bool,
        idSolicitud: u64
    ) acquires Dependencias, Solicitudes {
        let valor=idDependencia;
        assert!(exists<Solicitudes>(cuenta), ENO_INICIALIZADO);

         let dependencias = borrow_global_mut<Dependencias>(cuenta);
        assert!(table::contains(&dependencias.dependencias, IdDependencia { valor }), EREGISTRO_NO_EXISTE);

        valor=idSolicitud;
        let solicitudes = borrow_global_mut<Solicitudes>(cuenta);
        assert!(!table::contains(&solicitudes.solicitudes, IdSolicitud { valor }), EREGISTRO_YA_EXISTE);

        table::add(&mut solicitudes.solicitudes, IdSolicitud {
            valor,
        }, Solicitud {
            solicitante,
            correo,
            idDependencia,
            fecha,
            atendido,
        });
    }

    public entry fun add_Respuesta(
        responsable1:&signer,
        cuenta:address,
        idSolicitud: u64,
        informacion: String,
        anexos : String,
        fecha  : String,
        idRespuesta: u64
    ) acquires Solicitudes, Respuestas {
        let valor=idSolicitud;
        assert!(exists<Respuestas>(cuenta), ENO_INICIALIZADO);

         let solicitudes = borrow_global_mut<Solicitudes>(cuenta);
        assert!(table::contains(&solicitudes.solicitudes, IdSolicitud { valor }), EREGISTRO_NO_EXISTE);
        valor=idRespuesta;

        let respuestas = borrow_global_mut<Respuestas>(cuenta);
        assert!(!table::contains(&respuestas.respuestas, IdRespuesta { valor }), EREGISTRO_YA_EXISTE);
        let responsable=address_of(responsable1);
        let validacion: bool=false;
        let validador : address=@0x00;
        table::add(&mut respuestas.respuestas, IdRespuesta {
            valor,
        }, Respuesta {
            idSolicitud,
            informacion,
            anexos,
            fecha,
            responsable,
            validacion,
            validador
        });
    }

    #[view]
    public fun get_Dependencia(cuenta: address, idDependencia: u64): Dependencia acquires Dependencias {
        assert!(exists<Dependencias>(cuenta), ENO_INICIALIZADO);
        let valor=idDependencia;
        let dependencias = borrow_global<Dependencias>(cuenta);
        let depen = table::borrow(&dependencias.dependencias, IdDependencia { valor });
        *depen
    }

    #[view]
    public fun get_Enlace(cuenta: address, idEnlace: u64): Enlace acquires Enlaces {
        assert!(exists<Enlaces>(cuenta), ENO_INICIALIZADO);
        let valor=idEnlace;
        let enlaces = borrow_global<Enlaces>(cuenta);
        let enlac = table::borrow(&enlaces.enlaces, IdEnlace { valor });
        *enlac
    }

    #[view]
    public fun get_Solicitud(cuenta: address, idSolicitud: u64): Solicitud acquires Solicitudes {
        assert!(exists<Solicitudes>(cuenta), ENO_INICIALIZADO);
        let valor=idSolicitud;
        let solicitudes = borrow_global<Solicitudes>(cuenta);
        let solic = table::borrow(&solicitudes.solicitudes, IdSolicitud { valor });
        *solic
    }

    #[view]
    public fun get_Respuesta(cuenta: address, idRespuesta: u64): Respuesta acquires Respuestas {
        assert!(exists<Respuestas>(cuenta), ENO_INICIALIZADO);
        let valor=idRespuesta;
        let respuestas = borrow_global<Respuestas>(cuenta);
        let resp = table::borrow(&respuestas.respuestas, IdRespuesta { valor });
        *resp
    }

    public entry fun upd_Dep_direccion(cuenta: address, idDependencia: u64, direccion: String) acquires Dependencias {
        assert!(exists<Dependencias>(cuenta), ENO_INICIALIZADO);
        let dependencias = borrow_global_mut<Dependencias>(cuenta);
        let valor=idDependencia;
        assert!(table::contains(&dependencias.dependencias, IdDependencia { valor }), EREGISTRO_NO_EXISTE);
        let direccion_actual = &mut table::borrow_mut(&mut dependencias.dependencias, IdDependencia { valor }).direccion;
        *direccion_actual = direccion;
    }

    public entry fun upd_Dep_telefono(cuenta: address, idDependencia: u64, telefono: String) acquires Dependencias {
        assert!(exists<Dependencias>(cuenta), ENO_INICIALIZADO);
        let dependencias = borrow_global_mut<Dependencias>(cuenta);
        let valor=idDependencia;
        assert!(table::contains(&dependencias.dependencias, IdDependencia { valor }), EREGISTRO_NO_EXISTE);
        let telefono_actual = &mut table::borrow_mut(&mut dependencias.dependencias, IdDependencia { valor }).telefono;
        *telefono_actual = telefono;
    }
    public entry fun upd_Dep_correo(cuenta: address, idDependencia: u64, correo: String) acquires Dependencias {
        assert!(exists<Dependencias>(cuenta), ENO_INICIALIZADO);
        let dependencias = borrow_global_mut<Dependencias>(cuenta);
        let valor=idDependencia;
        assert!(table::contains(&dependencias.dependencias, IdDependencia { valor }), EREGISTRO_NO_EXISTE);
        let correo_actual = &mut table::borrow_mut(&mut dependencias.dependencias, IdDependencia { valor }).correo;
        *correo_actual = correo;
    }

    public entry fun upd_Enl_nombre(cuenta: address, idEnlace: u64, nombre: String) acquires Enlaces {
        assert!(exists<Enlaces>(cuenta), ENO_INICIALIZADO);
        let enlaces = borrow_global_mut<Enlaces>(cuenta);
        let valor=idEnlace;
        assert!(table::contains(&enlaces.enlaces, IdEnlace { valor }), EREGISTRO_NO_EXISTE);
        let nombre_actual = &mut table::borrow_mut(&mut enlaces.enlaces, IdEnlace { valor }).nombre;
        *nombre_actual = nombre;
    }
    public entry fun upd_Enl_cargo(cuenta: address, idEnlace: u64, cargo: String) acquires Enlaces {
        assert!(exists<Enlaces>(cuenta), ENO_INICIALIZADO);
        let enlaces = borrow_global_mut<Enlaces>(cuenta);
        let valor=idEnlace;
        assert!(table::contains(&enlaces.enlaces, IdEnlace { valor }), EREGISTRO_NO_EXISTE);
        let cargo_actual = &mut table::borrow_mut(&mut enlaces.enlaces, IdEnlace { valor }).cargo;
        *cargo_actual = cargo;
    }
    public entry fun upd_Enl_correo(cuenta: address, idEnlace: u64, correo: String) acquires Enlaces {
        assert!(exists<Enlaces>(cuenta), ENO_INICIALIZADO);
        let enlaces = borrow_global_mut<Enlaces>(cuenta);
        let valor=idEnlace;
        assert!(table::contains(&enlaces.enlaces, IdEnlace { valor }), EREGISTRO_NO_EXISTE);
        let correo_actual = &mut table::borrow_mut(&mut enlaces.enlaces, IdEnlace { valor }).correo;
        *correo_actual = correo;
    }
    public entry fun upd_Sol_atendido(cuenta: address, idSolicitud: u64, atendido: bool) acquires Solicitudes {
        assert!(exists<Solicitudes>(cuenta), ENO_INICIALIZADO);
        let solicitudes = borrow_global_mut<Solicitudes>(cuenta);
        let valor=idSolicitud;
        assert!(table::contains(&solicitudes.solicitudes, IdSolicitud { valor }), EREGISTRO_NO_EXISTE);
        let atendido_actual = &mut table::borrow_mut(&mut solicitudes.solicitudes, IdSolicitud { valor }).atendido;
        *atendido_actual = atendido;
    }
    public entry fun upd_Res_informacion(cuenta: address, idRespuesta: u64, informacion: String) acquires Respuestas {
        assert!(exists<Respuestas>(cuenta), ENO_INICIALIZADO);
        let respuestas = borrow_global_mut<Respuestas>(cuenta);
        let valor=idRespuesta;
        assert!(table::contains(&respuestas.respuestas, IdRespuesta { valor }), EREGISTRO_NO_EXISTE);
        let informacion_actual = &mut table::borrow_mut(&mut respuestas.respuestas, IdRespuesta { valor }).informacion;
        *informacion_actual = informacion;
    }
    public entry fun upd_Res_anexos(cuenta: address, idRespuesta: u64, anexos: String) acquires Respuestas {
        assert!(exists<Respuestas>(cuenta), ENO_INICIALIZADO);
        let respuestas = borrow_global_mut<Respuestas>(cuenta);
        let valor=idRespuesta;
        assert!(table::contains(&respuestas.respuestas, IdRespuesta { valor }), EREGISTRO_NO_EXISTE);
        let anexos_actual = &mut table::borrow_mut(&mut respuestas.respuestas, IdRespuesta { valor }).anexos;
        *anexos_actual = anexos;
    }
    public entry fun upd_Res_fecha(cuenta: address, idRespuesta: u64, fecha: String) acquires Respuestas {
        assert!(exists<Respuestas>(cuenta), ENO_INICIALIZADO);
        let respuestas = borrow_global_mut<Respuestas>(cuenta);
        let valor=idRespuesta;
        assert!(table::contains(&respuestas.respuestas, IdRespuesta { valor }), EREGISTRO_NO_EXISTE);
        let fecha_actual = &mut table::borrow_mut(&mut respuestas.respuestas, IdRespuesta { valor }).fecha;
        *fecha_actual = fecha;
    }

    public entry fun upd_Res_validado(validador: &signer, cuenta: address, idRespuesta: u64, validacion: bool) acquires Respuestas,Solicitudes {
        assert!(exists<Respuestas>(cuenta), ENO_INICIALIZADO);
        let respuestas = borrow_global_mut<Respuestas>(cuenta);
        let valor=idRespuesta;
        assert!(table::contains(&respuestas.respuestas, IdRespuesta { valor }), EREGISTRO_NO_EXISTE);
        let validacion_actual = &mut table::borrow_mut(&mut respuestas.respuestas, IdRespuesta { valor }).validacion;
        *validacion_actual = validacion;
        let validador_actual = &mut table::borrow_mut(&mut respuestas.respuestas, IdRespuesta { valor }).validador;
        *validador_actual = address_of(validador);
        let valor = table::borrow_mut(&mut respuestas.respuestas, IdRespuesta { valor }).idSolicitud;
        let idSolicitud=valor;
        let atendido=true;
        upd_Sol_atendido(cuenta, idSolicitud, atendido);
    }

    public entry fun erase_Dependencia(cuenta: address, idDependencia: u64) acquires Dependencias {
        assert!(exists<Dependencias>(cuenta), ENO_INICIALIZADO);
        let valor=idDependencia;
        let dependencias = borrow_global_mut<Dependencias>(cuenta);
        assert!(table::contains(&dependencias.dependencias, IdDependencia { valor }), EREGISTRO_NO_EXISTE);

        table::remove(&mut dependencias.dependencias, IdDependencia { valor });
    }

    public entry fun erase_Enlace(cuenta: address, idEnlace: u64) acquires Enlaces {
        assert!(exists<Enlaces>(cuenta), ENO_INICIALIZADO);
        let valor=idEnlace;
        let enlaces = borrow_global_mut<Enlaces>(cuenta);
        assert!(table::contains(&enlaces.enlaces, IdEnlace { valor }), EREGISTRO_NO_EXISTE);

        table::remove(&mut enlaces.enlaces, IdEnlace { valor });
    }

    public entry fun erase_Solicitud(cuenta: address, idDSolicitud: u64) acquires Solicitudes {
        assert!(exists<Solicitudes>(cuenta), ENO_INICIALIZADO);
        let valor=idDSolicitud;
        let solicitudes = borrow_global_mut<Solicitudes>(cuenta);
        assert!(table::contains(&solicitudes.solicitudes, IdSolicitud { valor }), EREGISTRO_NO_EXISTE);

        table::remove(&mut solicitudes.solicitudes, IdSolicitud { valor });
    }

    public entry fun erase_Respuesta(cuenta: address, idRespuesta: u64) acquires Respuestas, Solicitudes {
        assert!(exists<Respuestas>(cuenta), ENO_INICIALIZADO);
        let valor=idRespuesta;
        let respuestas = borrow_global_mut<Respuestas>(cuenta);
        assert!(table::contains(&respuestas.respuestas, IdRespuesta { valor }), EREGISTRO_NO_EXISTE);
        let valor = table::borrow_mut(&mut respuestas.respuestas, IdRespuesta { valor }).idSolicitud;
        let idSolicitud=valor;
        let atendido=false;
        upd_Sol_atendido(cuenta, idSolicitud, atendido);
        table::remove(&mut respuestas.respuestas, IdRespuesta { valor });
    }

}
