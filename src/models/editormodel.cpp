#include "editormodel.h"
#ifdef STATIC_MAUIKIT
#include "utils.h"
#else
#include <MauiKit/utils.h>
#endif

EditorModel::EditorModel(QObject *parent) : MauiList(parent),
    m_history(new HistoryModel(this)){}

FMH::MODEL_LIST EditorModel::items() const
{
    return this->m_list;
}

HistoryModel *EditorModel::getHistory() const
{
    return this->m_history;
}

void EditorModel::appendToHistory(const QUrl &url) const
{
    qDebug() << "APOPENIGN TO HISTORY "<< url;

    this->m_history->append(url);
}

bool EditorModel::append(const QUrl &url)
{
    qDebug()<< "Appending new file "<< url << this->contains(url);

    if(this->contains(url))
        return false;

    emit this->preItemAppended();
    if(url.isLocalFile()) //for now only support local files
    {
        if(FMH::fileExists(url))
            this->m_list << FMH::getFileInfoModel(url);
    }else
        this->m_list << FMH::MODEL {{FMH::MODEL_KEY::PATH, ""}, {FMH::MODEL_KEY::LABEL, "Untitled"}};

    this->appendToHistory(url);
    emit this->postItemAppended();

    return true;
}

bool EditorModel::contains(const QUrl &url) const
{
    return this->exists(FMH::MODEL_KEY::PATH, url.toString());
}

void EditorModel::remove(const int &index)
{
    if(index > this->getCount() || index < 0)
        return;

    emit this->preItemRemoved(index);
    this->m_list.remove(index);
    emit this->postItemRemoved();
}

void EditorModel::update(const int &index, const QUrl &url)
{
    qDebug() << "updating at index" << index;
    if(index > this->getCount() || index < 0)
        return;

    const auto item = FMH::getFileInfoModel(url);
    this->m_list[index] = item;

    emit this->updateModel(index, FMH::modelRoles(item));
}

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

    qDebug()<< urls;

    urls << url;

    qDebug()<< urls << QUrl::toStringList(urls);

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
