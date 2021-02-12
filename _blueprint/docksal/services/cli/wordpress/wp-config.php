<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */
define("WP_CONTENT_URL", '/wp-content');

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'default');

/** MySQL database username */
define('DB_USER', 'user');

/** MySQL database password */
define('DB_PASSWORD', 'user');

/** MySQL hostname */
define('DB_HOST', 'db:3306');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY', 'X.4X;=-k-04tM&CEEa i!B7UuWNLDd;kZ-tOctC1C[A%mQ=tZJ&KP~VWm,5G{;n#');
define('SECURE_AUTH_KEY', '0lXp-.N$r|CIrq|V1x,%Dsg@}&7,:bWD+38<_e{`p5r=Xip|1 H8?Ql%l=WA/{Ce');
define('LOGGED_IN_KEY', '0H|Sm5qXB<:8d5-qOQ#mqZuWFMxHOKU):j[3-&lBkB9>g4F(vp+OwE<wWhI$R|cF');
define('NONCE_KEY', 'xx2jnDD-Y{HiP?*;)*(ySF|JSN/CF1qWst+~ek>^%D=0:ju|M+a,Ct#8uW by=vP');
define('AUTH_SALT', '1%+7}Se3p1I{9-`6r=9[5Ov1)X|&Cw$t`A!n{^:fyvQduR!kHE]*/+?-?cLcPhAR');
define('SECURE_AUTH_SALT', '}|sN}li+YrN|jvIe!4Ou)V$|-cbo4c6~t){s,z MkqnB)Hu5_8~,-|2=H-6jI6XL');
define('LOGGED_IN_SALT', 'Ia@gt7-7Pmm!E#-fyRuS=VWDcu%6_NFO!=>POyI|&Id~+BjH+r^nXA!p]GfH{<qv');
define('NONCE_SALT', 'xyJI!IHHGQ~<.$X@V2haOBuhutP)EG]`8}q_<73Jrb2-sr AGg!<3zKUk-G`~ jP');

/**#@-*/
define('WP_HOME', 'http://' . $_SERVER['VIRTUAL_HOST']);
define('WP_SITEURL', 'http://' . $_SERVER['VIRTUAL_HOST']);
define("COOKIE_DOMAIN", $_SERVER['COOKIE_DOMAIN']);

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define('WP_DEBUG', false);

// If we're behind a proxy server and using HTTPS, we need to alert WordPress of that fact
// see also http://codex.wordpress.org/Administration_Over_SSL#Using_a_Reverse_Proxy
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
