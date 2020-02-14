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

class FilesFetcher : public QObject
{
		Q_OBJECT
	public slots:
		void fetch(const QList<QUrl> &urls);

	signals:
		void resultReady(FMH::MODEL_LIST items);
		void itemReady(FMH::MODEL item);
};

class DocumentsModel : public MauiList
{
		Q_OBJECT
		QThread m_worker;

	public:
		DocumentsModel(QObject *parent = nullptr);
		~DocumentsModel() override;

		FMH::MODEL_LIST items() const override final;

		void componentComplete() override final;

	private:
		void setList(const FMH::MODEL_LIST &list);
		void append(const FMH::MODEL &item);

		FMH::MODEL_LIST m_list;

	signals:
		void start(QList<QUrl> urls);
};


#endif // DOCUMENTSMODEL_H
