#ifndef DOCUMENTSMODEL_H
#define DOCUMENTSMODEL_H

#include <QObject>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

namespace FMH
{
class FileLoader;
}

class DocumentsModel : public MauiList
{
    Q_OBJECT
public:
    DocumentsModel(QObject *parent = nullptr);
    ~DocumentsModel() override;

    FMH::MODEL_LIST items() const override final;

    void componentComplete() override final;

private:
    void append(const FMH::MODEL_LIST &items);

    FMH::MODEL_LIST m_list;
    FMH::FileLoader *m_fileLoader;
};


#endif // DOCUMENTSMODEL_H
