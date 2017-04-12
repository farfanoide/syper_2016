Integrantes Grupo:
==================


Ruta, Santiago 12003/0
Karl, Ivan     12160/3


Se adjunta un script `setup.sh` el cual configura las carpetas necesarias dentro
de la máquina virtual. Tener a consideración que genera la carpeta
`/home/core/syper` borrando cualquiera que estuviera previamente en su lugar.

Punto 1:
--------

Se configuró ipsec entre la interfaz eth3 del nodo n62 y la eth1 del n19.

Punto 2:
--------

Tuvimos varias complicaciones para eliminar la cláusula `Listen 80` del archivo
`/etc/apache2/ports.conf` por lo que optamos por crear un virtualhost específico
para el puerto 80 el cual ejecuta un script php con retorno nulo para todos los
requests haciendo uso del `mod_rewrite`. La solución ideal (desde nuestro punto
de vista) seria simplemente eliminar la cláusula antes mencionada, pero CORE no
nos permitió hacer esto.

Punto 3:
--------

Se modificó el vhost para que escuche en el puerto 443 y se agregó un vhost en
el 80 el cual retorna un redirect al 443 ante cualquier petición.


> Nota: tanto para el punto 2 como para el 3 se crearon nuevos certificados
> (.pem) y claves (.key) y se configuraron en los respectivos vhosts.


Respuestas Punto 4:
-------------------

```
4. Con la protección implementada, ¿Es posible que un atacante que logró acceso
a una de las PCs de la sucursal ponga en riesgo alguna de las siguientes?

Justifique en cada caso:


1. Navegación WEB de otros usuarios de la sucursal
```


Si, ya que el host se encuentra dentro la misma subred y el tráfico dirigido
hacia/desde la web no está siendo encriptado por el túnel vpn.
Un usuario podría sin mayores problemas realizar, por ejemplo, ataques de
sniffing ya que la conexión entre hosts esta realizada con un HUB.

```
2. Navegación WEB de otros usuarios de la casa central
```

No, ya que el host comprometido no tiene acceso al trafico de los hosts
pertenecientes a la subred de casa central. 

```
3. Información confidencial en el servidor intranet.syper.edu
```

Previamente el servidor tenia habilitado el listado de directorios permitiendo
potencialmente el acceso a archivos privados/confidenciales. Esta opción fue
deshabilitado.  Se configuró el servidor para que solamente acepte conexiones
por https. Aun así el servidor podría ser vulnerado por ejemplo, si se realizan
los siguientes pasos:

1. Un host de la sucursal se quiere conectar con el servidor en cuestión
2. La máquina afectada realiza un SSLStrip sobre la conexión, ya que puede hacerlo porque hay un HUB en el medio
3. La máquina afectada espera a que el usuario se loguee a la aplicación DVWA y obtiene una cookie autenticada
4. El atacante se impersona ante el servidor como el usuario comprometido
5. Se dirige a la sección de file uploads y sube una shell maliciosa
6. El atacante gana acceso al servidor al correr este una aplicación vulnerable


```
4. Información de e-mails de otros usuarios
```

Considerando que los protocolos de mail transmiten en texto plano por defecto,
el atacante podría leer mails entrantes y salientes dentro de la subred de la
sucursal ya que la solución implementada (ipsec) encripta/desencripta los datos
a la altura del router de frontera.
