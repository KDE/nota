#include "editormodel.h"

EditorModel::EditorModel()
{

}

FMH::MODEL_LIST EditorModel::items() const
{
    return this->m_list;
}

void EditorModel::appendToHistory(const QUrl &url)
{

}

void EditorModel::append(const QUrl &url)
{
    qDebug()<< "Appending new file "<< url;
    emit this->preItemAppended();
    if(url.isLocalFile()) //for now only support local files
    {
        if(FMH::fileExists(url))
            this->m_list << FMH::getFileInfoModel(url);
    }else
        this->m_list << FMH::MODEL {{FMH::MODEL_KEY::PATH, ""}, {FMH::MODEL_KEY::LABEL, "Untitled"}};
    emit this->postItemAppended();
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
