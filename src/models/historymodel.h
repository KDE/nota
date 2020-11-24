#ifndef HISTORYMODEL_H
#define HISTORYMODEL_H

#include <QObject>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class HistoryModel : public MauiList
{
    Q_OBJECT

public:
    explicit HistoryModel(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override final;

    QList<QUrl> getHistory();

public slots:
    void append(const QUrl &url);

private:
    FMH::MODEL_LIST m_list;
    void setList();
};

#endif // HISTORYMODEL_H
