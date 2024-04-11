#pragma once

#include <QObject>

#include <MauiKit4/Core/fmh.h>
#include <MauiKit4/Core/mauilist.h>

class HistoryModel : public MauiList
{
    Q_OBJECT

public:
    explicit HistoryModel(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override final;

    QList<QUrl> getHistory();
    void componentComplete() override final;

public Q_SLOTS:
    void append(const QUrl &url);
    int indexOfName(const QString &query);

private:
    FMH::MODEL_LIST m_list;
    void setList();

};
