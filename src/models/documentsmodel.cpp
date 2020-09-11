#include "documentsmodel.h"

#ifdef STATIC_MAUIKIT
#include "fileloader.h"
#else
#include <MauiKit/fileloader.h>
#endif

static FMH::MODEL docInfo(const QUrl &url)
{
    auto item = FMH::getFileInfoModel (url);
    item[FMH::MODEL_KEY::PLACE] = FMH::fileDir(url);
    return item;
}

DocumentsModel::DocumentsModel(QObject * parent) : MauiList (parent)
  , m_fileLoader(new FMH::FileLoader())
{
    m_fileLoader->informer = &docInfo;
    connect(m_fileLoader, &FMH::FileLoader::itemReady, this, &DocumentsModel::append);
}

DocumentsModel::~DocumentsModel()
{
    delete m_fileLoader;
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

FMH::MODEL_LIST DocumentsModel::items() const
{
	return this->m_list;
}

void DocumentsModel::componentComplete()
{
     m_fileLoader->requestPath({FMH::DocumentsPath, FMH::DownloadsPath}, true, FMH::FILTER_LIST[FMH::FILTER_TYPE::TEXT]);
}
