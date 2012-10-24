/*
    KQRCode is a simple program to handle QR codes.
    Copyright (C) 2011  Anatoly Burakov <iburillo@users.sf.net>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/** FILE DESCRIPTION
 *
 * qrcodec.h
 * Header file for a QRCodec abstract class
 * This class is intended to be used as a base for
 * QR codecs. A QR codec is an object, whos sole
 * purpose is to aggregate data into specifically
 * formatted strings, which then are
 * supplied to the QR encoder; and to parse formatted
 * strings into more human readable data.
 *
 * An example of a formatted string would be:
 * Human readable form:
 * Send SMS message "Hello" to number +1234567890
 * Formatted form:
 * SMS:+1234567890:Hello
 *
 * The following links might be helpful for finding
 * different formats for QR codes:
 * http://www.nttdocomo.co.jp/english/service/imode/make/content/barcode/function/application/
 * http://code.google.com/p/zxing/wiki/BarcodeContents
 * http://www.qrstuff.com/
 * http://download.cnet.com/QR-Emoji-QR-Code-Reader-Scanner-Generator/3000-2124_4-11399494.html
 *
 * In order for QR plugin to be loadable, it must export
 * an instance() which returns QRCodec*.
 * 
 * Example (this should be defined in QR plugin's header):
 * 
 * extern "C" DLL_PUBLIC QRCodec* instance();
 * 
 * Implementation:
 * \code
 * extern "C" QRCodec* instance() {
 * 	return new CoolQRPlugin();
 * }
 * \endcode
 * For more information, check out QR codecs
 * provided in the kqrcode-plugins package.
 * 
 **/

/**
 * The following snippet is taken from GNU project
 */

#if defined _WIN32 || defined __CYGWIN__
#ifdef BUILDING_DLL
#ifdef __GNUC__
#define DLL_PUBLIC __attribute__ ((dllexport))
#else
#define DLL_PUBLIC __declspec(dllexport) // Note: actually gcc seems to also supports this syntax.
#endif
#else
#ifdef __GNUC__
#define DLL_PUBLIC __attribute__ ((dllimport))
#else
#define DLL_PUBLIC __declspec(dllimport) // Note: actually gcc seems to also supports this syntax.
#endif
#endif
#define DLL_LOCAL
#else
#if __GNUC__ >= 4
#define DLL_PUBLIC __attribute__ ((visibility ("default")))
#define DLL_LOCAL  __attribute__ ((visibility ("hidden")))
#else
#define DLL_PUBLIC
#define DLL_LOCAL
#endif
#endif

#ifndef QRCODEC_H
#define QRCODEC_H

#include <KDE/KLocalizedString>
#include <KDE/KDebug>

#include <QtCore/QString>
#include <QtGui/QWidget>
#include <QtGui/QPainter>
#include <QtGui/QLayout>
#include <QtCore/QObject>

#include <qrencode.h>


/** ENUM DESCRIPTION
 *
 * This enum describes the types of matching a plugin can do.
 *
 * NoMatch is pretty self-explanatory
 *
 * Fallback is a default value for QRText, because it accepts
 * everything that hasn't been matched by any other codec.
 * Better not use this value.
 *
 * Vague is a "vague" match. An example would be a website URL,
 * because while we certainly can match an URL, there might be
 * a plugin that tries to detect specific types of URLs like
 * mailto: URLs or ftp:// URLs.
 *
 * Exact is used when the plugin matches something specific, like
 * a mailto: URL or SMS message.
 *
 * Override is really here for debugging purposes, don't use it.
 */

enum Match_Priority {
    Match_NoMatch = -1,
    Match_Fallback = 0,
    Match_Vague,
    Match_Exact,
    Match_Override
};

/** ENUM DESCRIPTION
 * 
 * This enum describes types of errors a QR plugin can
 * encounter. The first one is obviously when there
 * are no errors. The "TooMuchData" error is returned
 * whenever a plugin is trying to squeeze too much
 * data into a QR code (there are limitations on
 * how much data QR code can carry).
 * 
 * The "UserError" is any user-defined error. It
 * notifies the main program that encoding is not
 * possible, but the error notifications are
 * supposed to be produced by the plugin itself
 * in the canEncode() call.
 */

enum Encode_Error {
    Error_NoError = 0,
    Error_TooMuchData,
    Error_UserError
};

#define VERSION 0

/**
 * Base class for plugins
 */

class QRCodec : public QObject
{

public:
    virtual ~QRCodec() {}
    
    /** VERSION
     * 
     * This is an ugly hack, sorry :-(
     * I couldn't think of something better.
     * Basically, every plugin returns VERSION
     * in version() call. Since it's #define'd,
     * whenever we have a recompile with the new
     * header, the compiled-in value changes.
     * At least, that's the general idea.
     * 
     * So, let me rephrase:
     * EVERY SUBCLASS'S version()
     * SHOULD ONLY CONTAIN THIS LINE:
     * \code
     * return VERSION;
     * \endcode
     * NOTHING ELSE.
     * 
     * Once again sorry for this ugly hack, but i
     * can't think of anything better.
     */
    virtual int version() const = 0;
    
    /** 
     * Must return internationalized plugin name
     * e.g. return i18n("SMS message");
     */
    virtual QString getName() const = 0;
    
    /**
     * This is where plugin processes whatever
     * user data it has and turns it into a string.
     * This string then goes to the encoder.
     */
    virtual QString encodeString() const = 0;
    
    /**
     * This is where plugin parses the incoming
     * data. Note that at this point it is known
     * that the data is valid.
     */
    virtual void decodeString ( const QString& ) = 0;
    
    /**
     * This is where plugin checks the incoming string
     * and looks if it can parse it. It should return
     * appropriate Match_Priority (see comments for that
     * enum).
     */
    virtual Match_Priority match ( const QString& ) const = 0;
    
    /**
     * Puts the plugin into a state that is clear of any
     * previous user input and ready to accept new input.
     */
    virtual void reset() = 0;
    
    /**
     * This function is called whenever the user interface
     * of the plugin is constructed. You can either setupUi with
     * Qt Designer form class, or manually add a layout and
     * all the UI elements.
     */
    virtual void createWidget ( QWidget * ) = 0;
    
    Encode_Error canEncode(int ec) {
	int dataLimit = 0;
	switch ( ec ) {
        case 0:
	    dataLimit = 2938;
            break;

        case 1:
	    dataLimit = 2319;
            break;

        case 2:
	    dataLimit = 1655;
            break;

        case 3:
	    dataLimit = 1268;
            break;
        }
        QString data = encodeString();
	if (data.toUtf8().size() > dataLimit)
	    return Error_TooMuchData;
	return canEncode();
    }

    /**
     * Initializes plugin GUI
     */
    void setupWidget ( QWidget* widget ) {
        clearWidget ( widget );
        createWidget ( widget );
        reset();
    }

    /**
     * Encodes contents of the QRCodec to QImage.
     */
    QImage encodeToImage ( int moduleSize, int ec ) {
        QString data = encodeString();
        int quietZone = 2; // modules
        QRecLevel ecLevel = QR_ECLEVEL_Q;
        QRinput * input = QRinput_new();

        switch ( ec ) {
        case 0:
            ecLevel = QR_ECLEVEL_L;
            break;
        case 1:
            ecLevel = QR_ECLEVEL_M;
            break;
        case 2:
            ecLevel = QR_ECLEVEL_Q;
            break;
        case 3:
            ecLevel = QR_ECLEVEL_H;
            break;
        }

        QRinput_setVersion ( input, 0 );

        QRinput_setErrorCorrectionLevel ( input, ecLevel );
        QRinput_append ( input, QR_MODE_8, data.toUtf8().size(), ( unsigned char * ) data.toUtf8().data() );

	
        QRcode * code;
	
	code = QRcode_encodeInput ( input );
	
	kDebug() << code << code->width;

        QImage result ( moduleSize * ( code->width + quietZone * 2 ),
                        moduleSize * ( code->width + quietZone * 2 ), QImage::Format_Mono );

        QPainter painter ( &result );

        // fill with white
        painter.fillRect ( 0,
                           0,
                           moduleSize * ( code->width + quietZone * 2 ),
                           moduleSize * ( code->width + quietZone * 2 ), QColor ( "#FFFFFF" ) );


        for ( int i = 0; i < code->width; i++ ) {
            for ( int j = 0; j < code->width; j++ ) {
                if ( ( code->data[ ( j * code->width ) + i] & 0x00000001 ) == 1 ) {
                    painter.fillRect ( moduleSize * ( i + quietZone ),
                                       moduleSize * ( j + quietZone ),
                                       moduleSize,
                                       moduleSize, QColor ( "#000000" ) );
                }
            }
        }

        return result;
    }

    /**
     * Character escaping function. Currently, escaped characters are:
     * : (colon)
     * ; (semicolon)
     * \ (forward slash)
     * , (comma)
     */
    static QString escape ( QString data ) {
        return data.replace ( "\\", "\\\\" ).replace ( ":", "\\:" ).replace ( ";", "\\;" ).replace ( ",", "\\," );
    }
    
    /**
     * Character unescaping function. Currently, unescaped characters are:
     * : (colon)
     * ; (semicolon)
     * \ (forward slash)
     * , (comma)
     */
    static QString unescape ( QString data ) {

        // unescaping requires a little more sophisticated patterns
        // instead, we just go through string and remove every occurence of backslash
        // this is a dirty dirty hack, but i can't think of anything better and
        // foolproof enough

        QString::iterator i = data.begin();

        while ( i != data.end() ) {
	    // check if there *is* a next symbol
            if ( *i == '\\' && i + 1 != data.end() ) {
                // check for escaped symbols
                if ( * ( i + 1 ) == '\\' ||
		     * ( i + 1 ) == ':' ||
		     * ( i + 1 ) == ';' ||
		     * ( i + 1 ) == ',' ) {
                    * ( i ) = QChar();
                    i++;
                }
            }

            i++;
        }

        // clean up invalid chars
        for ( int i = 0; i < data.length(); i++ )
            if ( data.at ( i ) == QChar() ) data.remove ( i, 1 );

        return data;
    }
    
protected:
    /**
     * Whenever the main application needs to know
     * whether the plugin is ready to encode something
     * (as opposed to some data missing), it will call
     * this function. It should return either
     * Error_NoError or Error_UserError. It is also
     * up to plugin to notify user why this Error_UserError
     * happened.
     */
    virtual Encode_Error canEncode() = 0;

private:
    // helper, clears out widget's contents
    void clearWidget ( QWidget* widget ) {
        if ( widget->layout() ) {
            while ( widget->findChildren<QWidget*>().count() ) {
                delete widget->findChildren<QWidget*>().at ( 0 );
            }

            delete widget->layout();
        }
    }
};

/**
 * This class is a convenience class for working
 * with DoCoMo-style strings (FOO:BAR:data;BAZ:moredata;;).
 */

class DocomoContainer : public QObject
{

public:
    explicit DocomoContainer ( QObject* = 0 ) {}
    
    DocomoContainer ( const DocomoContainer& c ) : QObject ( 0 ) {
        name = c.getName();
        data = c.getContents();
    }

    /**
     * Add DoCoMo tag.
     * Character escaping happens automatically.
     */
    static QString addDocomoTag ( QString tag, QString data ) {
        if ( !tag.length() ) return data;
	if (!DocomoContainer::isValidDocomoContainer(data))
	    data = QRCodec::escape(data);
        return tag + ":" + data + ";";
    }

    /**
     * Remove the DoCoMo tag.
     * Character unescaping happens automatically.
     */
    static QString removeDocomoTag ( QString data ) {
        if ( data.length() == 0 ) return data;
	
	QString result = data.mid ( data.indexOf ( ":" ) + 1, data.lastIndexOf ( ";" ) - data.indexOf ( ":" ) - 1 );
	if (DocomoContainer::isValidDocomoContainer(result))
	    return result;
	else
	    return QRCodec::unescape(result);
    }

    /**
     * Checks if the string can be identified as a valid
     * DoCoMo-style data container.
     */
    static bool isValidDocomoContainer ( QString str ) {
        // check for number of open and closed tags
        int tagsOpen = 0, tagsClosed = 0;

        for ( int i = 0; i < str.count(); i++ ) {
            if ( str.at ( i ) == ':' ) {
                // check if it's not an escaped \:
                if ( str.at ( i - 1 ) != '\\' ) tagsOpen++;
            }

            if ( str.at ( i ) == ';' ) {
                // check if it's not an escaped \;
                if ( str.at ( i - 1 ) != '\\' ) tagsClosed++;
            }
        }

        return ( tagsOpen == tagsClosed ) && ( tagsOpen > 0 );
    }
    
    /**
     * Parses string into a list of DoCoMo containers.
     */
    static QList<DocomoContainer> parseString ( QString &str ) {
        if ( !isValidDocomoContainer ( str ) ) {
            return QList<DocomoContainer>();
        }

        QList<DocomoContainer> tags;

        int tagStartIndex = 0, contentStartIndex = 0, contentEndIndex = - 1;

        while ( contentEndIndex < str.lastIndexOf ( ';' ) ) {
            int tagsOpen = 0, tagsClosed = 0;
            tagStartIndex = contentEndIndex + 1;

            QString name, contents;
            DocomoContainer container;

            for ( int i = tagStartIndex; i < str.length(); i++ ) {
                if ( str.at ( i ) == ':' ) {
                    // check if it's not an escaped \:
                    if ( str.at ( i - 1 ) != '\\' ) {
                        if ( tagsOpen == 0 ) {
                            container.setName ( QRCodec::unescape( str.mid ( tagStartIndex, i - tagStartIndex ) ) );
                            contentStartIndex = i + 1;
                        }

                        tagsOpen++;
                    }
                }

                if ( str.at ( i ) == ';' ) {
                    // check if it's not an escaped \;
                    if ( str.at ( i - 1 ) != '\\' ) {
                        tagsClosed++;

                        if ( tagsClosed == tagsOpen ) {
                            container.setContents ( QRCodec::unescape( str.mid ( contentStartIndex, i - contentStartIndex ) ) );
                            tags.append ( container );
                            contentEndIndex = i;
                            break;
                        }
                    }
                }
            }
        }

        return tags;
    }
    
    /**
     * Set tag name for DoCoMo container.
     */
    void setName ( QString n ) {
        name = n;
    }

    /**
     * Get tag name for DoCoMo container
     */
    QString getName() const {
        return name;
    }

    /**
     * Get contents of the DoCoMo container
     */
    QString getContents() const {
        return data;
    }

    /**
     * Set contents of the DoCoMo container
     */
    void setContents ( QString str ) {
        data = str;
    }

    /**
     * Convenience function. Returns the whole string.
     */
    QString toString() {
        return addDocomoTag ( name, data );
    }

private:
    QString name;
    QString data;
};

#endif
