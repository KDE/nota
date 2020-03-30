#ifndef NOTA_H
#define NOTA_H

#include <QObject>
#include <QFileInfo>

#ifdef STATIC_MAUIKIT
#include "fmstatic.h"
#else
#include <MauiKit/fmstatic.h>
#endif

class Nota :  public QObject
{
    Q_OBJECT
public slots:
    void requestFiles(const QStringList &urls)
    {
        qDebug() << "REQUEST FILES" << urls;
        QStringList res;
        for(const auto &url : urls)
        {
            const auto url_ = QUrl::fromUserInput(url);
            qDebug() << "REQUEST FILES" << url_.toString() << FMH::getMime(url_);

            if(FMStatic::checkFileType(FMH::FILTER_TYPE::TEXT, FMH::getMime(url_)))
                res << url_.toString();
        }

        qDebug() << "REQUEST FILES" << res;

        emit this->openFiles(res);
    }

signals:
    void openFiles(QStringList urls);
};


#endif // NOTA_H
