#ifndef EDITORMODEL_H
#define EDITORMODEL_H

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
    FMH::MODEL_LIST items() const override final;

    void append(const QUrl &url);
    QList<QUrl> getHistory();

private:
    FMH::MODEL_LIST m_list;
    void setList();
};

class EditorModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(HistoryModel * history READ getHistory CONSTANT FINAL)
    Q_PROPERTY(QStringList urls READ getUrls NOTIFY urlsChanged)

public:
    explicit EditorModel(QObject *parent = nullptr);

    FMH::MODEL_LIST items() const override final;
    HistoryModel *getHistory() const;

    QStringList getUrls() const;

private:
    FMH::MODEL_LIST m_list;
    void appendToHistory(const QUrl &url) const;

    HistoryModel *m_history;

public slots:
    bool append(const QUrl &url);
    bool contains(const QUrl &url) const;
    void remove(const int &index);
    void update(const int &index, const QUrl &url);
    int urlIndex(const QUrl &url);
    QVariantList getFiles() const;

signals:
    void urlsChanged();
};

#endif // EDITORMODEL_H
