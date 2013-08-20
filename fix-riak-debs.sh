cd /debs
for i in orig/*.deb
  do
  PKGNAME=`echo $i | sed -e s#orig/##g| sed -e s/.deb//g`
  PKGBASE=`echo $i | sed -e s#orig/##g| cut -d '_' -f 1`
  dpkg-deb --extract orig/$PKGNAME.deb new/$PKGNAME
  dpkg-deb --control orig/$PKGNAME.deb new/$PKGNAME/DEBIAN
  perl -pi -e 's#chmod\ \-R\ \+X\ /etc/#chmod -R +X /etc/'$PKGBASE'/#' new/$PKGNAME/DEBIAN/postinst
  dpkg-deb --build new/$PKGNAME
done
