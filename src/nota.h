#ifndef NOTA_H
#define NOTA_H

#include <QObject>
#include <QFileInfo>
#include <QProcess>

#ifdef STATIC_MAUIKIT
#include "fmstatic.h"
#else
#include <MauiKit/fmstatic.h>
#endif

class Nota :  public QObject
{
	Q_OBJECT

public:
    static Nota * instance()
    {
        static Nota nota;
        return &nota;
    }

    Nota(const Nota &) = delete;
    Nota &operator=(const Nota &) = delete;
    Nota(Nota &&) = delete;
    Nota &operator=(Nota &&) = delete;


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

	bool supportsEmbededTerminal()
	{
#ifdef EMBEDDED_TERMINAL
		return true;
#else
		return false;
#endif
	}

    bool run(const QString &process, const QStringList &params = {})
    {
            auto m_process = new QProcess;
//            connect(myProcess,SIGNAL(readyReadStandardError()),this,SLOT(vEdProcess()));
//            connect(myProcess,SIGNAL(readyReadStandardOutput()),this,SLOT(processStandardOutput()));
            connect(m_process,SIGNAL(finished(int)),m_process,SLOT(deleteLater()));
            connect(this,&QObject::destroyed,m_process,&QProcess::kill);
            m_process->start(process, params);
            return true;
    }

signals:
	void openFiles(QStringList urls);

private:
    explicit Nota(QObject *parent = nullptr) {}
};


#endif // NOTA_H
