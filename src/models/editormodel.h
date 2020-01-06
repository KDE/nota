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

class EditorModel : public MauiList
{
    Q_OBJECT
public:
    EditorModel();

    FMH::MODEL_LIST items() const override final;

private:
    FMH::MODEL_LIST m_list;
    void appendToHistory(const QUrl &url);

public slots:
    void append(const QUrl &url);
    bool contains(const QUrl &url) const;
    void remove(const int &index);
    void update(const int &index, const QUrl &url);
};

#endif // EDITORMODEL_H
