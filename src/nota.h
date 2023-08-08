#ifndef NOTA_H
#define NOTA_H

#include <QFileInfo>
#include <QObject>
#include <QProcess>
#include <QDebug>

#include <MauiKit3/FileBrowsing/fmstatic.h>

class Nota : public QObject
{
    Q_OBJECT

public:
    static Nota *instance()
    {
        static Nota nota;
        return &nota;
    }

    Nota(const Nota &) = delete;
    Nota &operator=(const Nota &) = delete;
    Nota(Nota &&) = delete;
    Nota &operator=(Nota &&) = delete;

public slots:    
    bool run(const QString &process, const QStringList &params = {})
    {
        auto m_process = new QProcess;
        //            connect(myProcess,SIGNAL(readyReadStandardError()),this,SLOT(vEdProcess()));
        //            connect(myProcess,SIGNAL(readyReadStandardOutput()),this,SLOT(processStandardOutput()));
        connect(m_process, SIGNAL(finished(int)), m_process, SLOT(deleteLater()));
        connect(this, &QObject::destroyed, m_process, &QProcess::kill);
        m_process->start(process, params);
        return true;
    }

private:
    explicit Nota(QObject *parent = nullptr)
        : QObject(parent)
    {
    }
};

#endif // NOTA_H
