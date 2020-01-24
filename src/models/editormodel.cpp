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

QStringList EditorModel::getUrls() const
{
    return std::accumulate(this->m_list.constBegin(), this->m_list.constEnd(), QStringList(), [](QStringList &urls, const FMH::MODEL &item)
    {
        urls << item[FMH::MODEL_KEY::PATH];
        return urls;
    });
}
void EditorModel::appendToHistory(const QUrl &url) const
{
    qDebug() << "APOPENIGN TO HISTORY "<< url;

    this->m_history->append(url);
}

bool EditorModel::append(const QUrl &url)
{
    qDebug()<< "Appending new file "<< url << this->contains(url);

    emit this->preItemAppended();
    if(!url.isEmpty())
    {
        if(this->contains(url))
            return false;

        if(url.isLocalFile() && FMH::fileExists(url)) //for now only support local files
        {
                this->m_list << FMH::getFileInfoModel(url);
                this->appendToHistory(url);
        }

    }else this->m_list << FMH::MODEL {{FMH::MODEL_KEY::ICON, "text-plain"}, {FMH::MODEL_KEY::PATH, ""}, {FMH::MODEL_KEY::LABEL, "Untitled"}};

    emit this->postItemAppended();
    emit this->urlsChanged();
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

    const auto index_ = this->mappedIndex(index);

    emit this->preItemRemoved(index_);
    this->m_list.remove(index_);
    emit this->postItemRemoved();
}

void EditorModel::update(const int &index, const QUrl &url)
{
    qDebug() << "updating at index" << index;
    if(index > this->getCount() || index < 0)
        return;

    const auto index_ = this->mappedIndex(index);

    const auto item = FMH::getFileInfoModel(url);
    this->m_list[index_] = item;

    emit this->updateModel(index_, FMH::modelRoles(item));
}

int EditorModel::urlIndex(const QUrl &url)
{
    return this->indexOf(FMH::MODEL_KEY::PATH, url.toString());
}

QVariantList EditorModel::getFiles() const
{
    return FMH::toMapList(this->m_list);
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
