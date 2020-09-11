#include "historymodel.h"
#ifdef STATIC_MAUIKIT
#include "utils.h"
#else
#include <MauiKit/utils.h>
#endif

HistoryModel::HistoryModel(QObject *parent) : MauiList(parent)
{
    this->setList();
}

FMH::MODEL_LIST HistoryModel::items() const
{
    return this->m_list;
}

void HistoryModel::append(const QUrl &url)
{
    auto urls = this->getHistory();
    if(urls.contains(url.toString()))
        return;

    emit this->preItemAppended();
    this->m_list << FMH::getFileInfoModel(url);
    emit this->postItemAppended();

    urls << url;

    UTIL::saveSettings("URLS", QUrl::toStringList(urls), "HISTORY");
}

QList<QUrl> HistoryModel::getHistory()
{
    auto res =  QUrl::fromStringList(UTIL::loadSettings("URLS", "HISTORY", QStringList()).toStringList());
    res.removeAll({});
    return res;
}

void HistoryModel::setList()
{
    for(const auto &url : this->getHistory())
    {
        if(url.isLocalFile() && !FMH::fileExists(url))
            continue;

        emit this->preItemAppended();
        this->m_list << FMH::getFileInfoModel(url);
        emit this->postItemAppended();
    }
}
