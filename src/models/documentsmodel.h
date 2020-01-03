#ifndef DOCUMENTSMODEL_H
#define DOCUMENTSMODEL_H

#include <QObject>
#include <QThread>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class FileLoader : public QObject
{
		Q_OBJECT
	public slots:
		void fetch(const QList<QUrl> &urls);

	signals:
		void resultReady(FMH::MODEL_LIST items);
};

class DocumentsModel : public MauiList
{
		Q_OBJECT
		QThread m_worker;

	public:
		DocumentsModel(QObject *parent = nullptr);
		~DocumentsModel();

		FMH::MODEL_LIST items() const override final;

		void componentComplete() override final;

	private:
		void setList(const FMH::MODEL_LIST &list);
		FMH::MODEL_LIST m_list;

	signals:
		void start(QList<QUrl> urls);
};


#endif // DOCUMENTSMODEL_H
