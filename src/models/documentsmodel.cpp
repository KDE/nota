#include "documentsmodel.h"
#include <QDirIterator>

Q_DECLARE_METATYPE (FMH::MODEL_LIST)

DocumentsModel::DocumentsModel(QObject * parent) : MauiList (parent)
{
	qRegisterMetaType<FMH::MODEL_LIST>("MODEL_LIST");
	FileLoader *loader = new FileLoader;
	loader->moveToThread(&m_worker);

	connect(&m_worker, &QThread::finished, loader, &QObject::deleteLater);

	connect(this, &DocumentsModel::start, loader, &FileLoader::fetch);
	connect(loader, &FileLoader::resultReady, this, &DocumentsModel::setList);

	m_worker.start();
}

DocumentsModel::~DocumentsModel()
{
	m_worker.quit();
	m_worker.wait();
}

void DocumentsModel::setList(const FMH::MODEL_LIST &list)
{
	emit this->preListChanged ();
	this->m_list = list;
	emit this->postListChanged ();
}

void FileLoader::fetch(const QList<QUrl> & urls)
{
	FMH::MODEL_LIST res;

	for(const auto &url : urls)
	{
		QDirIterator it(url.toLocalFile(), FMH::FILTER_LIST[FMH::FILTER_TYPE::TEXT], QDir::Files, QDirIterator::Subdirectories);

		while (it.hasNext())
			res << FMH::getFileInfoModel (QUrl::fromLocalFile (it.next ()));
	}

	emit this->resultReady(res);
}

FMH::MODEL_LIST DocumentsModel::items() const
{
	return this->m_list;
}

void DocumentsModel::componentComplete()
{
	emit this->start({FMH::HomePath});
}
