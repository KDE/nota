#include "documentsmodel.h"
#include <QDirIterator>

Q_DECLARE_METATYPE (FMH::MODEL_LIST)
Q_DECLARE_METATYPE (FMH::MODEL)

DocumentsModel::DocumentsModel(QObject * parent) : MauiList (parent)
{
	qRegisterMetaType<FMH::MODEL_LIST>("MODEL_LIST");
	qRegisterMetaType<FMH::MODEL>("MODEL");

    FilesFetcher *loader = new FilesFetcher;
	loader->moveToThread(&m_worker);

	connect(&m_worker, &QThread::finished, loader, &QObject::deleteLater);

    connect(this, &DocumentsModel::start, loader, &FilesFetcher::fetch);
    connect(loader, &FilesFetcher::itemReady, this, &DocumentsModel::append);

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


void DocumentsModel::append(const FMH::MODEL &item)
{
	emit this->preItemAppended ();
	this->m_list << item;
	emit this->postItemAppended ();
}

void FilesFetcher::fetch(const QList<QUrl> & urls)
{
	FMH::MODEL_LIST res;

	for(const auto &url : urls)
	{
		QDirIterator it(url.toLocalFile(), FMH::FILTER_LIST[FMH::FILTER_TYPE::TEXT], QDir::Files | QDir::NoDotAndDotDot | QDir::NoSymLinks, QDirIterator::Subdirectories);

		while (it.hasNext())
		{
            const auto url = QUrl::fromLocalFile (it.next());
            auto item = FMH::getFileInfoModel (url);
            item[FMH::MODEL_KEY::PLACE] = FMH::fileDir(url);
			res << item;
			emit this->itemReady (item);
		}
	}
//	emit this->resultReady(res);
}

FMH::MODEL_LIST DocumentsModel::items() const
{
	return this->m_list;
}

void DocumentsModel::componentComplete()
{
    emit this->start({FMH::DocumentsPath, FMH::DownloadsPath, FMH::DesktopPath});
}
