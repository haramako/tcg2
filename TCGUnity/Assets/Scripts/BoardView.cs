using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using MRuby;
using DG.Tweening;

[CustomMRubyClass]
public class BoardObject : MonoBehaviour
{
    [HideInInspector]
    public int ObjectID;

    public void MoveTo(float x, float y, float duration)
    {
        transform.SetAsLastSibling();
        float scale = 1 / 1280.0f;
        transform.DOLocalMove(new Vector3(x*scale, 0, y*scale), duration);
    }
}

[CustomMRubyClass]
public class BoardView : MonoBehaviour
{
    public BoardObject[] Templates;

    Dictionary<int, BoardObject> objects = new Dictionary<int, BoardObject>();

    private void Awake()
    {
        foreach (var t in Templates)
        {
            t.gameObject.SetActive(false);
        }
    }

    public BoardObject Create(string templateName, int id)
    {
        if (objects.TryGetValue(id, out var bobj))
        {
            bobj.transform.SetAsLastSibling();
            return bobj;
        }

        var template = Templates.First(t => t.name == templateName);
        var obj = GameObject.Instantiate(template.gameObject);
        //obj.transform.SetParent(transform, false);
        obj.name = $"{templateName}:{id}";

        bobj = obj.GetComponent<BoardObject>();
        bobj.ObjectID = id;
        objects.Add(id, bobj);

        obj.SetActive(true);

        return bobj;
    }

    public BoardObject Find(int id)
    {
        return objects[id];
    }

    public void Clear()
    {
        foreach( var obj in objects.Values)
        {
            Destroy(obj.gameObject);
        }
        objects.Clear();
    }

}
