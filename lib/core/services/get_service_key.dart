import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final Scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "new-version-nearme",
        "private_key_id": "0b92b4f345f3605f572f3b59487debbc1951a891",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCln+j29sP9Bu9Z\n1RCbZCl1EA3agfe1SR/r01q+gA1bKmwuUumWrWQFqhm2VGKZ0sel0ZY7JMJmaiGz\n1wnNsa8maKoS/txwAmvCn99l6krB+aq9TKzXnRpwUc/ZgT+dSrBcvwN+5O6Pp1pm\nZMZn+GTo1LeyoSRarGVD2G+5B7x4QS/1My+uI+Dn26LL2cO/TMasAKmMwcITGar5\nXjlSf8mbDYNXD2ZOe43UKlZYj2Ofz5oUP+9Ue58SnSW52+ODC+pdRtMW05lPFtRW\nfR+EFrJ0pvokyd9DeyA+Fv59gwzwrTaZk1TEMo3MM/immGWOooLBT90cfIIxD/3t\nXw6wfSeFAgMBAAECggEAB+0/ldmebITRXfFd1ltkmuLuECQSF4B8sTQgHsfGUTOW\nUmBAUuhmW1lhBNIvQZFDjLWGH7taZ32TB9urRIeJbF3sLTUP6/dzB1v7RzzU9PQu\nnlk7WNAUJMXcRrASJpnIF47tIKddyI0ip+MRANxengBs8J/C5j5j1AEEQII03GTJ\n0hW6i4ip37Af3mAPjx0lNnl3nZPDZEFE7zx9M1Fqo+m+sKBxkIo2ekWrFEveM2q9\nGV0TraHD8zk7IlepXAr2ajyOBMK/bP55M83zIiVuKHVKY9Fk9+TFOaqQJHQEJzIv\nmMifXB889kSsJxI6xyC2RAl/Zj4S6QR9Bt4IGQyiuQKBgQDj+4kfGeJvXb7pG4HE\nghCSpsdUHpYz/ndnpTTFTJbeLY76DbPzU3qHHmxuoRWlwe64xfC7yTzjvpewZq2X\njGj0nLCngKkL7ruV7DOuItgapbsZNbOyn+77h+/W2Ow3MVkJIAaHD6u0DP0o7DeM\nyi/oA2ffADtY0tG/5kx45pohPQKBgQC5+o7eZZ8WMcgmw4lR2xgImo4+F0cftICl\n+gPONmiEsuYe75SpNbf/X1S9U3wfVeUi8fjYvbWrPmC+1fuTTQJY1w3lV7UFf2EY\n8ZUnq+RfwoGSGKCKTHEt9brWPeUJRYAsOc8sjUt10Aep1LIp5mUCnttCOJB7N1ja\nT0WnPcjz6QKBgHHLc74aZXPBDzG7kSJM6YjJxmSuf7qkIWWSiKySdhugEeWuQUwL\nNvWKsgTmUq/SBR4lbuvMnp/u2jgqiCtE4n52V5bEGZzjJK7In2Mj8Uobvy/uJiva\nuKbES2qqC/3gm9h6K8fugn30nch3X6LeqNreGFKvAvBrClcG1NTkBbrhAoGBAIdj\nzmo9FKl1qD4AD5HVrBNnYLH3BEIih51M+0Q9+6zPCBPxWgotHzv7zJbflfbB80OT\nYBN5WC3IBWooITNE1raSKH2TcicEak1cYbc1vdWwpd8TqpvDtok84L1i5b/wJrUL\niLToT8z+mvWZ7/Hs1hAoUXpN73CkBD05hH2Rzx8xAoGAJVHE7GOSHjDP2ucNvBrW\nxpKiI2NIBA1ZEg85gxQwZEpCSRbMyqi/v9QdBQcADbwwL4G1M88zl+bkguxAZwIY\ngUdS4UA06j+gZ/2/9etb655hNKqq8aqXiXdzItjBTrjJVPtLOdvYVG7r8psaiscR\ntOpr9IJ4saA25FBYuGpW2KE=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@new-version-nearme.iam.gserviceaccount.com",
        "client_id": "109044763724723769436",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40new-version-nearme.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      Scopes,
    );

    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
